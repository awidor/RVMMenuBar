import CoreML
import CoreVideo
import Foundation
import QuartzCore

final class RVMCoreMLRunner {
    private let model: rvm_mobilenetv3_1920x1080_s0_25_fp16
    private var r1: MLMultiArray?
    private var r2: MLMultiArray?
    private var r3: MLMultiArray?
    private var r4: MLMultiArray?

    init() throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        model = try rvm_mobilenetv3_1920x1080_s0_25_fp16(contentsOf: ModelLocator.loadModelURL(), configuration: configuration)
    }

    func resetState() {
        r1 = nil
        r2 = nil
        r3 = nil
        r4 = nil
    }

    func predict(src: CVPixelBuffer, profiler: FrameProfiler?) throws -> (fgr: CVPixelBuffer, pha: CVPixelBuffer, inferenceMs: Double) {
        let start = CACurrentMediaTime()
        let output = try profiler?.measure("coreml.prediction") {
            try model.prediction(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)
        } ?? model.prediction(src: src, r1i: r1, r2i: r2, r3i: r3, r4i: r4)
        let elapsedMs = (CACurrentMediaTime() - start) * 1000.0

        if let profiler {
            profiler.measure("coreml.store_recurrent_state") {
                r1 = output.r1o
                r2 = output.r2o
                r3 = output.r3o
                r4 = output.r4o
            }
        } else {
            r1 = output.r1o
            r2 = output.r2o
            r3 = output.r3o
            r4 = output.r4o
        }

        return (output.fgr, output.pha, elapsedMs)
    }
}
