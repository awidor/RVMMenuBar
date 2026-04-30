//
// rvm_mobilenetv3_1920x1080_s0_25_fp16.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class rvm_mobilenetv3_1920x1080_s0_25_fp16Input : MLFeatureProvider {

    /// Source frame as color (kCVPixelFormatType_32BGRA) image buffer, 1920 pixels wide by 1080 pixels high
    var src: CVPixelBuffer

    /// Recurrent state 1. Initial state is an all zero tensor. Subsequent state is received from r1o. as optional 1 × 16 × 135 × 240 4-dimensional array of floats
    var r1i: MLMultiArray? = nil

    /// Recurrent state 2. Initial state is an all zero tensor. Subsequent state is received from r2o. as optional 1 × 20 × 68 × 120 4-dimensional array of floats
    var r2i: MLMultiArray? = nil

    /// Recurrent state 3. Initial state is an all zero tensor. Subsequent state is received from r3o. as optional 1 × 40 × 34 × 60 4-dimensional array of floats
    var r3i: MLMultiArray? = nil

    /// Recurrent state 4. Initial state is an all zero tensor. Subsequent state is received from r4o. as optional 1 × 64 × 17 × 30 4-dimensional array of floats
    var r4i: MLMultiArray? = nil

    var featureNames: Set<String> { ["src", "r1i", "r2i", "r3i", "r4i"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "src" {
            return MLFeatureValue(pixelBuffer: src)
        }
        if featureName == "r1i" {
            return r1i == nil ? nil : MLFeatureValue(multiArray: r1i!)
        }
        if featureName == "r2i" {
            return r2i == nil ? nil : MLFeatureValue(multiArray: r2i!)
        }
        if featureName == "r3i" {
            return r3i == nil ? nil : MLFeatureValue(multiArray: r3i!)
        }
        if featureName == "r4i" {
            return r4i == nil ? nil : MLFeatureValue(multiArray: r4i!)
        }
        return nil
    }

    init(src: CVPixelBuffer, r1i: MLMultiArray? = nil, r2i: MLMultiArray? = nil, r3i: MLMultiArray? = nil, r4i: MLMultiArray? = nil) {
        self.src = src
        self.r1i = r1i
        self.r2i = r2i
        self.r3i = r3i
        self.r4i = r4i
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    convenience init(src: CVPixelBuffer, r1i: MLShapedArray<Float>? = nil, r2i: MLShapedArray<Float>? = nil, r3i: MLShapedArray<Float>? = nil, r4i: MLShapedArray<Float>? = nil) {
        self.init(src: src, r1i: r1i != nil ? MLMultiArray(r1i!) : nil, r2i: r2i != nil ? MLMultiArray(r2i!) : nil, r3i: r3i != nil ? MLMultiArray(r3i!) : nil, r4i: r4i != nil ? MLMultiArray(r4i!) : nil)
    }

    convenience init(srcWith src: CGImage, r1i: MLMultiArray? = nil, r2i: MLMultiArray? = nil, r3i: MLMultiArray? = nil, r4i: MLMultiArray? = nil) throws {
        self.init(src: try MLFeatureValue(cgImage: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, r1i: r1i, r2i: r2i, r3i: r3i, r4i: r4i)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    convenience init(srcWith src: CGImage, r1i: MLShapedArray<Float>? = nil, r2i: MLShapedArray<Float>? = nil, r3i: MLShapedArray<Float>? = nil, r4i: MLShapedArray<Float>? = nil) throws {
        self.init(src: try MLFeatureValue(cgImage: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, r1i: r1i != nil ? MLMultiArray(r1i!) : nil, r2i: r2i != nil ? MLMultiArray(r2i!) : nil, r3i: r3i != nil ? MLMultiArray(r3i!) : nil, r4i: r4i != nil ? MLMultiArray(r4i!) : nil)
    }

    convenience init(srcAt src: URL, r1i: MLMultiArray? = nil, r2i: MLMultiArray? = nil, r3i: MLMultiArray? = nil, r4i: MLMultiArray? = nil) throws {
        self.init(src: try MLFeatureValue(imageAt: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, r1i: r1i, r2i: r2i, r3i: r3i, r4i: r4i)
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    convenience init(srcAt src: URL, r1i: MLShapedArray<Float>? = nil, r2i: MLShapedArray<Float>? = nil, r3i: MLShapedArray<Float>? = nil, r4i: MLShapedArray<Float>? = nil) throws {
        self.init(src: try MLFeatureValue(imageAt: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!, r1i: r1i != nil ? MLMultiArray(r1i!) : nil, r2i: r2i != nil ? MLMultiArray(r2i!) : nil, r3i: r3i != nil ? MLMultiArray(r3i!) : nil, r4i: r4i != nil ? MLMultiArray(r4i!) : nil)
    }

    func setSrc(with src: CGImage) throws  {
        self.src = try MLFeatureValue(cgImage: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setSrc(with src: URL) throws  {
        self.src = try MLFeatureValue(imageAt: src, pixelsWide: 1920, pixelsHigh: 1080, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class rvm_mobilenetv3_1920x1080_s0_25_fp16Output : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// Foreground prediction as color (kCVPixelFormatType_32BGRA) image buffer, 1920 pixels wide by 1080 pixels high
    var fgr: CVPixelBuffer {
        provider.featureValue(for: "fgr")!.imageBufferValue!
    }

    /// Alpha prediction as grayscale (kCVPixelFormatType_OneComponent8) image buffer, 1920 pixels wide by 1080 pixels high
    var pha: CVPixelBuffer {
        provider.featureValue(for: "pha")!.imageBufferValue!
    }

    /// Recurrent state 1. Needs to be passed as r1i input in the next time step. as multidimensional array of floats
    var r1o: MLMultiArray {
        provider.featureValue(for: "r1o")!.multiArrayValue!
    }

    /// Recurrent state 1. Needs to be passed as r1i input in the next time step. as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var r1oShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(r1o)
    }

    /// Recurrent state 2. Needs to be passed as r2i input in the next time step. as multidimensional array of floats
    var r2o: MLMultiArray {
        provider.featureValue(for: "r2o")!.multiArrayValue!
    }

    /// Recurrent state 2. Needs to be passed as r2i input in the next time step. as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var r2oShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(r2o)
    }

    /// Recurrent state 3. Needs to be passed as r3i input in the next time step. as multidimensional array of floats
    var r3o: MLMultiArray {
        provider.featureValue(for: "r3o")!.multiArrayValue!
    }

    /// Recurrent state 3. Needs to be passed as r3i input in the next time step. as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var r3oShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(r3o)
    }

    /// Recurrent state 4. Needs to be passed as r4i input in the next time step. as multidimensional array of floats
    var r4o: MLMultiArray {
        provider.featureValue(for: "r4o")!.multiArrayValue!
    }

    /// Recurrent state 4. Needs to be passed as r4i input in the next time step. as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var r4oShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(r4o)
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(fgr: CVPixelBuffer, pha: CVPixelBuffer, r1o: MLMultiArray, r2o: MLMultiArray, r3o: MLMultiArray, r4o: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["fgr" : MLFeatureValue(pixelBuffer: fgr), "pha" : MLFeatureValue(pixelBuffer: pha), "r1o" : MLFeatureValue(multiArray: r1o), "r2o" : MLFeatureValue(multiArray: r2o), "r3o" : MLFeatureValue(multiArray: r3o), "r4o" : MLFeatureValue(multiArray: r4o)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class rvm_mobilenetv3_1920x1080_s0_25_fp16 {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "rvm_mobilenetv3_1920x1080_s0.25_fp16", withExtension:"mlmodelc")!
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of rvm_mobilenetv3_1920x1080_s0_25_fp16.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `rvm_mobilenetv3_1920x1080_s0_25_fp16.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<rvm_mobilenetv3_1920x1080_s0_25_fp16, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16 {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<rvm_mobilenetv3_1920x1080_s0_25_fp16, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(rvm_mobilenetv3_1920x1080_s0_25_fp16(model: model)))
            }
        }
    }

    /**
        Construct rvm_mobilenetv3_1920x1080_s0_25_fp16 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16 {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return rvm_mobilenetv3_1920x1080_s0_25_fp16(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Input

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Output
    */
    func prediction(input: rvm_mobilenetv3_1920x1080_s0_25_fp16Input) throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16Output {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Output
    */
    func prediction(input: rvm_mobilenetv3_1920x1080_s0_25_fp16Input, options: MLPredictionOptions) throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16Output {
        let outFeatures = try model.prediction(from: input, options: options)
        return rvm_mobilenetv3_1920x1080_s0_25_fp16Output(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Output
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: rvm_mobilenetv3_1920x1080_s0_25_fp16Input, options: MLPredictionOptions = MLPredictionOptions()) async throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16Output {
        let outFeatures = try await model.prediction(from: input, options: options)
        return rvm_mobilenetv3_1920x1080_s0_25_fp16Output(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - src: Source frame as color (kCVPixelFormatType_32BGRA) image buffer, 1920 pixels wide by 1080 pixels high
            - r1i: Recurrent state 1. Initial state is an all zero tensor. Subsequent state is received from r1o. as optional 1 × 16 × 135 × 240 4-dimensional array of floats
            - r2i: Recurrent state 2. Initial state is an all zero tensor. Subsequent state is received from r2o. as optional 1 × 20 × 68 × 120 4-dimensional array of floats
            - r3i: Recurrent state 3. Initial state is an all zero tensor. Subsequent state is received from r3o. as optional 1 × 40 × 34 × 60 4-dimensional array of floats
            - r4i: Recurrent state 4. Initial state is an all zero tensor. Subsequent state is received from r4o. as optional 1 × 64 × 17 × 30 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Output
    */
    func prediction(src: CVPixelBuffer, r1i: MLMultiArray?, r2i: MLMultiArray?, r3i: MLMultiArray?, r4i: MLMultiArray?) throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16Output {
        let input_ = rvm_mobilenetv3_1920x1080_s0_25_fp16Input(src: src, r1i: r1i, r2i: r2i, r3i: r3i, r4i: r4i)
        return try prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - src: Source frame as color (kCVPixelFormatType_32BGRA) image buffer, 1920 pixels wide by 1080 pixels high
            - r1i: Recurrent state 1. Initial state is an all zero tensor. Subsequent state is received from r1o. as optional 1 × 16 × 135 × 240 4-dimensional array of floats
            - r2i: Recurrent state 2. Initial state is an all zero tensor. Subsequent state is received from r2o. as optional 1 × 20 × 68 × 120 4-dimensional array of floats
            - r3i: Recurrent state 3. Initial state is an all zero tensor. Subsequent state is received from r3o. as optional 1 × 40 × 34 × 60 4-dimensional array of floats
            - r4i: Recurrent state 4. Initial state is an all zero tensor. Subsequent state is received from r4o. as optional 1 × 64 × 17 × 30 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as rvm_mobilenetv3_1920x1080_s0_25_fp16Output
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func prediction(src: CVPixelBuffer, r1i: MLShapedArray<Float>?, r2i: MLShapedArray<Float>?, r3i: MLShapedArray<Float>?, r4i: MLShapedArray<Float>?) throws -> rvm_mobilenetv3_1920x1080_s0_25_fp16Output {
        let input_ = rvm_mobilenetv3_1920x1080_s0_25_fp16Input(src: src, r1i: r1i, r2i: r2i, r3i: r3i, r4i: r4i)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [rvm_mobilenetv3_1920x1080_s0_25_fp16Input]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [rvm_mobilenetv3_1920x1080_s0_25_fp16Output]
    */
    func predictions(inputs: [rvm_mobilenetv3_1920x1080_s0_25_fp16Input], options: MLPredictionOptions = MLPredictionOptions()) throws -> [rvm_mobilenetv3_1920x1080_s0_25_fp16Output] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [rvm_mobilenetv3_1920x1080_s0_25_fp16Output] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  rvm_mobilenetv3_1920x1080_s0_25_fp16Output(features: outProvider)
            results.append(result)
        }
        return results
    }
}
