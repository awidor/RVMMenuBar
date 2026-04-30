import AVFoundation
import CoreVideo
import Foundation
import QuartzCore

struct CameraFrame {
    let pixelBuffer: CVPixelBuffer
    let samplePTSSeconds: Double
    let outputTime: CFTimeInterval
}

final class CameraCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrame: ((CameraFrame) -> Void)?
    var onError: ((String) -> Void)?

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "rvm.capture.session")
    private let frameQueue = DispatchQueue(label: "rvm.capture.frames", qos: .userInteractive)
    private var isConfigured = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.configureAndStart()
                } else {
                    self?.onError?("Camera access denied")
                }
            }
        case .denied, .restricted:
            onError?("Camera access denied")
        @unknown default:
            onError?("Unknown camera authorization state")
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                if !isConfigured {
                    try configureSession()
                    isConfigured = true
                }
                if !session.isRunning {
                    session.startRunning()
                }
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    private func configureSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080

        guard let device = AVCaptureDevice.default(for: .video) else {
            throw NSError(domain: "RVMMenuBar.CameraCapture", code: 1, userInfo: [NSLocalizedDescriptionKey: "No video capture device found"])
        }

        try configureDevice(device)

        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw NSError(domain: "RVMMenuBar.CameraCapture", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not add camera input"])
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: frameQueue)

        guard session.canAddOutput(output) else {
            throw NSError(domain: "RVMMenuBar.CameraCapture", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not add video output"])
        }
        session.addOutput(output)

        if let connection = output.connection(with: .video), connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }

        session.commitConfiguration()
    }

    private func configureDevice(_ device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }

        if let format = device.formats.first(where: { format in
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            return dimensions.width == 1920 && dimensions.height == 1080
        }) {
            device.activeFormat = format
        }

        let frameDuration = CMTime(value: 1, timescale: 30)
        if device.activeFormat.videoSupportedFrameRateRanges.contains(where: { $0.maxFrameRate >= 30 }) {
            device.activeVideoMinFrameDuration = frameDuration
            device.activeVideoMaxFrameDuration = frameDuration
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        onFrame?(CameraFrame(
            pixelBuffer: pixelBuffer,
            samplePTSSeconds: pts.seconds.isFinite ? pts.seconds : 0,
            outputTime: CACurrentMediaTime()
        ))
    }
}
