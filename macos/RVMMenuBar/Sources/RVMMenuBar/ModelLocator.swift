import CoreML
import Foundation

enum ModelLocator {
    static let modelBaseName = "rvm_mobilenetv3_1920x1080_s0.25_fp16"

    static func loadModelURL() throws -> URL {
        if let override = ProcessInfo.processInfo.environment["RVM_MODEL_PATH"], !override.isEmpty {
            return try preparedModelURL(from: URL(fileURLWithPath: override))
        }

        if let bundledCompiled = Bundle.main.url(forResource: modelBaseName, withExtension: "mlmodelc") {
            return bundledCompiled
        }

        if let bundledModel = Bundle.main.url(forResource: modelBaseName, withExtension: "mlmodel") {
            return try preparedModelURL(from: bundledModel)
        }

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let repoModel = cwd.appendingPathComponent("models/\(modelBaseName).mlmodel")
        if FileManager.default.fileExists(atPath: repoModel.path) {
            return try preparedModelURL(from: repoModel)
        }

        let sourceRelativeModel = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("models/\(modelBaseName).mlmodel")
        if FileManager.default.fileExists(atPath: sourceRelativeModel.path) {
            return try preparedModelURL(from: sourceRelativeModel)
        }

        throw NSError(
            domain: "RVMMenuBar.ModelLocator",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Could not find \(modelBaseName).mlmodel or .mlmodelc"]
        )
    }

    private static func preparedModelURL(from url: URL) throws -> URL {
        if url.pathExtension == "mlmodelc" {
            return url
        }
        return try MLModel.compileModel(at: url)
    }
}
