import Foundation
import os
import QuartzCore

struct AppConfiguration {
    var autoStart = false
    var showPreviewOnStart = true
    var quitAfterProfiledFrames: Int?
    var profiling = ProfilingConfiguration()

    static func parse(arguments: [String]) throws -> AppConfiguration {
        var configuration = AppConfiguration()
        var index = 1

        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--help", "-h":
                throw CommandLineRequest.help
            case "--start", "--auto-start":
                configuration.autoStart = true
            case "--no-preview":
                configuration.showPreviewOnStart = false
            case "--profile":
                configuration.profiling.isEnabled = true
            case "--profile-debug":
                configuration.profiling.isEnabled = true
                configuration.profiling.consoleOutput = true
                configuration.profiling.signposts = true
                configuration.profiling.includeOverlayDetails = true
                configuration.profiling.logEveryFrames = 1
            case "--profile-console":
                configuration.profiling.isEnabled = true
                configuration.profiling.consoleOutput = true
            case "--profile-no-console":
                configuration.profiling.consoleOutput = false
            case "--profile-no-signposts":
                configuration.profiling.signposts = false
            case "--profile-jsonl":
                index += 1
                guard index < arguments.count else {
                    throw CommandLineRequest.error("--profile-jsonl requires a file path")
                }
                configuration.profiling.isEnabled = true
                configuration.profiling.jsonlPath = arguments[index]
            case "--profile-every":
                index += 1
                guard index < arguments.count, let value = Int(arguments[index]), value > 0 else {
                    throw CommandLineRequest.error("--profile-every requires a positive integer")
                }
                configuration.profiling.isEnabled = true
                configuration.profiling.logEveryFrames = value
            case "--profile-frames":
                index += 1
                guard index < arguments.count, let value = Int(arguments[index]), value > 0 else {
                    throw CommandLineRequest.error("--profile-frames requires a positive integer")
                }
                configuration.profiling.isEnabled = true
                configuration.autoStart = true
                configuration.quitAfterProfiledFrames = value
            default:
                throw CommandLineRequest.error("Unknown argument: \(argument)")
            }
            index += 1
        }

        return configuration
    }

    static let usage = """
    Usage:
      RVMMenuBar [options]

    Options:
      --start, --auto-start          Start camera + inference on launch.
      --no-preview                   Do not open the preview window on auto-start.
      --profile                      Enable profiling overlay and signposts.
      --profile-debug                Enable detailed per-frame profiling to stdout.
      --profile-console              Print per-frame profile summaries to stdout.
      --profile-no-console           Disable stdout profile summaries.
      --profile-no-signposts         Disable os_signpost intervals.
      --profile-jsonl PATH           Write detailed per-frame timings as JSONL.
      --profile-every N              Log every Nth profiled frame. Default: 1.
      --profile-frames N             Auto-start and quit after N profiled frames.
      --help                         Show this help.

    Example:
      .build/RVMMenuBar.app/Contents/MacOS/RVMMenuBar --profile-debug --profile-jsonl /tmp/rvm-profile.jsonl --profile-frames 300 --no-preview
    """
}

enum CommandLineRequest: Error, CustomStringConvertible {
    case help
    case error(String)

    var description: String {
        switch self {
        case .help:
            return AppConfiguration.usage
        case .error(let message):
            return "\(message)\n\n\(AppConfiguration.usage)"
        }
    }
}

struct ProfilingConfiguration: Equatable {
    var isEnabled = false
    var consoleOutput = false
    var signposts = true
    var includeOverlayDetails = true
    var logEveryFrames = 1
    var jsonlPath: String?
}

struct ProfileStage: Codable {
    let name: String
    let depth: Int
    let startMs: Double
    let durationMs: Double
}

struct FrameProfileSnapshot: Codable {
    let frameIndex: Int
    let timestamp: String
    let fps: Double
    let previewMode: String
    let droppedFramesSinceLastAccepted: Int
    let totalMs: Double
    let accountedMs: Double
    let unaccountedMs: Double
    let stages: [ProfileStage]
}

final class FrameProfiler {
    private static let log = OSLog(subsystem: "dev.local.RVMMenuBar", category: "Profiling")

    let frameIndex: Int
    let droppedFramesSinceLastAccepted: Int

    private let configuration: ProfilingConfiguration
    private let startTime: CFTimeInterval
    private let signpostID: OSSignpostID
    private let lock = NSLock()
    private var stages: [ProfileStage] = []
    private var depth = 0
    private var isFinished = false

    init(
        frameIndex: Int,
        droppedFramesSinceLastAccepted: Int,
        startTime: CFTimeInterval = CACurrentMediaTime(),
        configuration: ProfilingConfiguration
    ) {
        self.frameIndex = frameIndex
        self.droppedFramesSinceLastAccepted = droppedFramesSinceLastAccepted
        self.configuration = configuration
        self.startTime = startTime
        signpostID = OSSignpostID(log: Self.log)

        if configuration.signposts {
            os_signpost(.begin, log: Self.log, name: "Frame", signpostID: signpostID, "frame=%{public}d", frameIndex)
        }
    }

    func measure<T>(_ name: String, _ body: () throws -> T) rethrows -> T {
        let token = begin(name)
        do {
            let value = try body()
            end(token)
            return value
        } catch {
            end(token)
            throw error
        }
    }

    func begin(_ name: String) -> ProfileToken {
        lock.lock()
        let token = ProfileToken(name: name, depth: depth, start: CACurrentMediaTime())
        depth += 1
        lock.unlock()

        if configuration.signposts {
            os_signpost(.begin, log: Self.log, name: "Stage", signpostID: signpostID, "%{public}@", name as NSString)
        }

        return token
    }

    func end(_ token: ProfileToken) {
        let now = CACurrentMediaTime()
        let stage = ProfileStage(
            name: token.name,
            depth: token.depth,
            startMs: (token.start - startTime) * 1000.0,
            durationMs: (now - token.start) * 1000.0
        )

        lock.lock()
        stages.append(stage)
        depth = max(0, depth - 1)
        lock.unlock()

        if configuration.signposts {
            os_signpost(.end, log: Self.log, name: "Stage", signpostID: signpostID, "%{public}@", token.name as NSString)
        }
    }

    func record(_ name: String, startedAt start: CFTimeInterval) {
        record(name, startedAt: start, endedAt: CACurrentMediaTime())
    }

    func record(_ name: String, startedAt start: CFTimeInterval, endedAt end: CFTimeInterval) {
        let now = CACurrentMediaTime()
        let stage = ProfileStage(
            name: name,
            depth: 0,
            startMs: (start - startTime) * 1000.0,
            durationMs: ((end >= start ? end : now) - start) * 1000.0
        )
        lock.lock()
        stages.append(stage)
        lock.unlock()
    }

    func snapshot(fps: Double, previewMode: PreviewMode) -> FrameProfileSnapshot {
        makeSnapshot(fps: fps, previewMode: previewMode, finish: true)
    }

    func overlaySummary(fps: Double, previewMode: PreviewMode) -> String {
        let snapshot = makeSnapshot(fps: fps, previewMode: previewMode, finish: false)
        return Self.format(snapshot, multiline: true, maximumStages: 12)
    }

    private func makeSnapshot(fps: Double, previewMode: PreviewMode, finish: Bool) -> FrameProfileSnapshot {
        lock.lock()
        if finish, !isFinished, configuration.signposts {
            os_signpost(.end, log: Self.log, name: "Frame", signpostID: signpostID, "frame=%{public}d", frameIndex)
        }
        if finish {
            isFinished = true
        }
        let capturedStages = stages.sorted { lhs, rhs in
            if lhs.startMs == rhs.startMs {
                return lhs.durationMs > rhs.durationMs
            }
            return lhs.startMs < rhs.startMs
        }
        lock.unlock()

        let totalMs = (CACurrentMediaTime() - startTime) * 1000.0
        let topLevelMs = capturedStages
            .filter { $0.depth == 0 }
            .reduce(0.0) { $0 + $1.durationMs }
        return FrameProfileSnapshot(
            frameIndex: frameIndex,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            fps: fps,
            previewMode: previewMode.rawValue,
            droppedFramesSinceLastAccepted: droppedFramesSinceLastAccepted,
            totalMs: totalMs,
            accountedMs: topLevelMs,
            unaccountedMs: max(0.0, totalMs - topLevelMs),
            stages: capturedStages
        )
    }

    static func format(_ snapshot: FrameProfileSnapshot, multiline: Bool, maximumStages: Int = 16) -> String {
        let prefix = String(
            format: "#%d  %.1f FPS  total %.3f ms  dropped %d",
            snapshot.frameIndex,
            snapshot.fps,
            snapshot.totalMs,
            snapshot.droppedFramesSinceLastAccepted
        )
        let visibleStages = snapshot.stages
            .filter { $0.depth <= 1 }
            .sorted { $0.durationMs > $1.durationMs }
            .prefix(maximumStages)
            .map { stage in
                String(format: "%@ %.3f", stage.name, stage.durationMs)
            }

        if multiline {
            return ([prefix] + visibleStages).joined(separator: "\n")
        }
        return ([prefix] + visibleStages).joined(separator: " | ")
    }
}

struct ProfileToken {
    let name: String
    let depth: Int
    let start: CFTimeInterval
}

final class ProfilingReporter {
    private let queue = DispatchQueue(label: "rvm.profile.report")
    private let encoder = JSONEncoder()
    private var configuration: ProfilingConfiguration
    private var handle: FileHandle?
    private var reportedFrames = 0

    init(configuration: ProfilingConfiguration) {
        self.configuration = configuration
        encoder.outputFormatting = [.sortedKeys]
        openJSONLIfNeeded(path: configuration.jsonlPath)
    }

    deinit {
        close()
    }

    func update(configuration: ProfilingConfiguration) {
        queue.async { [weak self] in
            guard let self else { return }
            let previousPath = self.configuration.jsonlPath
            self.configuration = configuration
            if previousPath != configuration.jsonlPath {
                self.handle?.closeFile()
                self.handle = nil
                self.openJSONLIfNeeded(path: configuration.jsonlPath)
            }
        }
    }

    func report(_ snapshot: FrameProfileSnapshot) {
        queue.async { [weak self] in
            guard let self else { return }
            guard self.configuration.isEnabled else { return }
            guard snapshot.frameIndex % max(self.configuration.logEveryFrames, 1) == 0 else { return }

            self.reportedFrames += 1
            if self.configuration.consoleOutput {
                print(FrameProfiler.format(snapshot, multiline: false))
            }

            guard let handle = self.handle else { return }
            do {
                let data = try self.encoder.encode(snapshot)
                handle.write(data)
                handle.write(Data("\n".utf8))
            } catch {
                print("Profile JSONL write failed: \(error.localizedDescription)")
            }
        }
    }

    func close() {
        queue.sync {
            handle?.closeFile()
            handle = nil
        }
    }

    private func openJSONLIfNeeded(path: String?) {
        guard let path, !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        let directory = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: url.path) {
                FileManager.default.createFile(atPath: url.path, contents: nil)
            }
            handle = try FileHandle(forWritingTo: url)
            try handle?.truncate(atOffset: 0)
        } catch {
            print("Profile JSONL open failed at \(path): \(error.localizedDescription)")
        }
    }
}
