import Foundation
import QuartzCore

struct FrameTiming {
    let inferenceMs: Double
    let compositeMs: Double
    let endToEndMs: Double
    let fps: Double
    let profileDetails: String?

    static let zero = FrameTiming(inferenceMs: 0, compositeMs: 0, endToEndMs: 0, fps: 0, profileDetails: nil)

    var summary: String {
        String(format: "%.1f FPS  %.1f ms inf  %.1f ms comp", fps, inferenceMs, compositeMs)
    }

    var overlay: String {
        profileDetails ?? summary
    }
}

final class FPSCounter {
    private var frameCount = 0
    private var windowStart = CACurrentMediaTime()
    private(set) var fps = 0.0

    func tick() -> Double {
        frameCount += 1
        let now = CACurrentMediaTime()
        let elapsed = now - windowStart
        if elapsed >= 1.0 {
            fps = Double(frameCount) / elapsed
            frameCount = 0
            windowStart = now
        }
        return fps
    }
}
