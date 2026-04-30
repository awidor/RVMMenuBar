import AppKit
import CoreVideo
import Foundation
import QuartzCore

enum RuntimeState {
    case stopped
    case starting
    case running
    case failed(String)

    var label: String {
        switch self {
        case .stopped:
            return "Stopped"
        case .starting:
            return "Starting"
        case .running:
            return "Running"
        case .failed(let message):
            return "Error: \(message)"
        }
    }
}

final class RuntimeController {
    var onFrame: ((ProcessedFrame) -> Void)?
    var onStateChange: ((RuntimeState) -> Void)?
    var onProfilingModeChange: ((Bool) -> Void)?

    private let camera = CameraCapture()
    private let inferenceQueue = DispatchQueue(label: "rvm.inference", qos: .userInteractive)
    private let compositor = FrameCompositor()
    private let fpsCounter = FPSCounter()
    private let profileReporter: ProfilingReporter
    private let stateLock = NSLock()
    private var profilingConfiguration: ProfilingConfiguration
    private var runner: RVMCoreMLRunner?
    private var inFlight = false
    private var started = false
    private var didLogPixelBuffers = false
    private var acceptedFrameCount = 0
    private var droppedFrameCount = 0
    private var completedProfiledFrames = 0
    private var quitAfterProfiledFrames: Int?
    private(set) var state: RuntimeState = .stopped {
        didSet { onStateChange?(state) }
    }

    var backgroundMode: BackgroundMode {
        get { compositor.backgroundMode }
        set { compositor.backgroundMode = newValue }
    }

    var previewMode: PreviewMode = .composite

    var isProfilingEnabled: Bool {
        get { profilingConfiguration.isEnabled }
        set {
            profilingConfiguration.isEnabled = newValue
            if newValue {
                profilingConfiguration.consoleOutput = true
                profilingConfiguration.includeOverlayDetails = true
            }
            profileReporter.update(configuration: profilingConfiguration)
            onProfilingModeChange?(newValue)
        }
    }

    init(configuration: AppConfiguration = AppConfiguration()) {
        profilingConfiguration = configuration.profiling
        profileReporter = ProfilingReporter(configuration: configuration.profiling)
        quitAfterProfiledFrames = configuration.quitAfterProfiledFrames
        camera.onFrame = { [weak self] pixelBuffer in
            self?.process(pixelBuffer)
        }
        camera.onError = { [weak self] message in
            self?.setState(.failed(message))
        }
    }

    func start() {
        guard !started else { return }
        started = true
        setState(.starting)

        inferenceQueue.async { [weak self] in
            guard let self else { return }
            do {
                runner = try RVMCoreMLRunner()
                setState(.running)
                camera.start()
            } catch {
                started = false
                setState(.failed(error.localizedDescription))
            }
        }
    }

    func stop() {
        started = false
        camera.stop()
        inferenceQueue.async { [weak self] in
            self?.runner?.resetState()
            self?.runner = nil
            self?.setInFlight(false)
            self?.setState(.stopped)
        }
    }

    func resetRecurrentState() {
        inferenceQueue.async { [weak self] in
            self?.runner?.resetState()
        }
    }

    func completeFrame(_ frame: ProcessedFrame) {
        guard let profiler = frame.profiler else { return }
        let snapshot = profiler.snapshot(fps: frame.timing.fps, previewMode: previewMode)
        profileReporter.report(snapshot)

        completedProfiledFrames += 1
        if let quitAfterProfiledFrames, completedProfiledFrames >= quitAfterProfiledFrames {
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }

    func closeProfiler() {
        profileReporter.close()
    }

    private func process(_ cameraFrame: CameraFrame) {
        let processStart = CACurrentMediaTime()
        guard started else { return }
        guard let claim = claimFrame() else { return }
        let claimEnd = CACurrentMediaTime()

        let retainedPixelBuffer = cameraFrame.pixelBuffer
        let profiler = makeProfiler(frameIndex: claim.frameIndex, droppedFrames: claim.droppedFrames, startTime: cameraFrame.outputTime)
        profiler?.record("camera.callback_to_runtime", startedAt: cameraFrame.outputTime, endedAt: processStart)
        profiler?.record("runtime.claim_inflight", startedAt: processStart, endedAt: claimEnd)
        let enqueueTime = CACurrentMediaTime()
        inferenceQueue.async { [weak self] in
            guard let self else { return }
            defer { setInFlight(false) }

            guard let runner else { return }
            profiler?.record("inference_queue.wait", startedAt: enqueueTime)
            let frameStart = CACurrentMediaTime()

            do {
                if !didLogPixelBuffers {
                    profiler?.measure("debug.describe_camera_buffer") {
                        PixelBufferDebug.describe("Camera", retainedPixelBuffer)
                    }
                }
                let prediction = try profiler?.measure("runtime.inference_total") {
                    try runner.predict(src: retainedPixelBuffer, profiler: profiler)
                } ?? runner.predict(src: retainedPixelBuffer, profiler: nil)
                if !didLogPixelBuffers {
                    profiler?.measure("debug.describe_model_outputs") {
                        PixelBufferDebug.describe("Foreground", prediction.fgr)
                        PixelBufferDebug.describe("Alpha", prediction.pha)
                        self.didLogPixelBuffers = true
                    } ?? {
                        PixelBufferDebug.describe("Foreground", prediction.fgr)
                        PixelBufferDebug.describe("Alpha", prediction.pha)
                        self.didLogPixelBuffers = true
                    }()
                }
                let composite: (image: CGImage, compositeMs: Double)
                composite = profiler?.measure("runtime.preview_render_total") {
                    switch self.previewMode {
                    case .composite:
                        return self.compositor.composite(foreground: prediction.fgr, alpha: prediction.pha, profiler: profiler)
                    case .camera:
                        return self.compositor.render(pixelBuffer: retainedPixelBuffer, mode: .camera, profiler: profiler)
                    case .foreground:
                        return self.compositor.render(pixelBuffer: prediction.fgr, mode: .foreground, profiler: profiler)
                    case .alpha:
                        return self.compositor.render(pixelBuffer: prediction.pha, mode: .alpha, profiler: profiler)
                    }
                } ?? {
                    switch self.previewMode {
                    case .composite:
                        return self.compositor.composite(foreground: prediction.fgr, alpha: prediction.pha, profiler: nil)
                    case .camera:
                        return self.compositor.render(pixelBuffer: retainedPixelBuffer, mode: .camera, profiler: nil)
                    case .foreground:
                        return self.compositor.render(pixelBuffer: prediction.fgr, mode: .foreground, profiler: nil)
                    case .alpha:
                        return self.compositor.render(pixelBuffer: prediction.pha, mode: .alpha, profiler: nil)
                    }
                }()
                let endToEndMs = (CACurrentMediaTime() - frameStart) * 1000.0
                let fps = fpsCounter.tick()
                let profileDetails = profilingConfiguration.includeOverlayDetails ? profiler?.overlaySummary(fps: fps, previewMode: previewMode) : nil
                let timing = FrameTiming(
                    inferenceMs: prediction.inferenceMs,
                    compositeMs: composite.compositeMs,
                    endToEndMs: endToEndMs,
                    fps: fps,
                    profileDetails: profileDetails
                )
                onFrame?(ProcessedFrame(image: composite.image, timing: timing, profiler: profiler))
            } catch {
                started = false
                camera.stop()
                setState(.failed(error.localizedDescription))
            }
        }
    }

    private func setState(_ newState: RuntimeState) {
        DispatchQueue.main.async { [weak self] in
            self?.state = newState
        }
    }

    private func claimFrame() -> (frameIndex: Int, droppedFrames: Int)? {
        stateLock.lock()
        defer { stateLock.unlock() }
        if inFlight {
            droppedFrameCount += 1
            return nil
        }
        inFlight = true
        acceptedFrameCount += 1
        let claim = (acceptedFrameCount, droppedFrameCount)
        droppedFrameCount = 0
        return claim
    }

    @discardableResult
    private func setInFlight(_ value: Bool) -> Bool {
        stateLock.lock()
        inFlight = value
        stateLock.unlock()
        return value
    }

    private func makeProfiler(frameIndex: Int? = nil, droppedFrames: Int, startTime: CFTimeInterval = CACurrentMediaTime()) -> FrameProfiler? {
        guard profilingConfiguration.isEnabled else { return nil }
        return FrameProfiler(
            frameIndex: frameIndex ?? acceptedFrameCount,
            droppedFramesSinceLastAccepted: droppedFrames,
            startTime: startTime,
            configuration: profilingConfiguration
        )
    }
}
