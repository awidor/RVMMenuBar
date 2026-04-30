import CoreImage
import CoreImage.CIFilterBuiltins
import CoreVideo
import Foundation
import QuartzCore

enum BackgroundMode: String {
    case green = "Green"
    case checkerboard = "Checkerboard"
}

enum PreviewMode: String {
    case composite = "Composite"
    case camera = "Raw Camera"
    case foreground = "Foreground"
    case alpha = "Alpha"
}

struct ProcessedFrame {
    let image: CGImage
    let timing: FrameTiming
    let profiler: FrameProfiler?
}

final class FrameCompositor {
    var backgroundMode: BackgroundMode = .green
    private let renderContext = CIContext(options: [.cacheIntermediates: false])
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

    func composite(foreground: CVPixelBuffer, alpha: CVPixelBuffer, profiler: FrameProfiler?) -> (image: CGImage, compositeMs: Double) {
        let start = CACurrentMediaTime()
        let fgrImage = profiler?.measure("ci.wrap_foreground") {
            CIImage(cvPixelBuffer: foreground, options: [.colorSpace: rgbColorSpace])
        } ?? CIImage(cvPixelBuffer: foreground, options: [.colorSpace: rgbColorSpace])
        let alphaImage = profiler?.measure("ci.wrap_alpha") {
            CIImage(cvPixelBuffer: alpha)
        } ?? CIImage(cvPixelBuffer: alpha)
        let background = profiler?.measure("ci.background") {
            backgroundImage(extent: fgrImage.extent)
        } ?? backgroundImage(extent: fgrImage.extent)

        let filter = CIFilter.blendWithMask()
        if let profiler {
            profiler.measure("ci.configure_blend_mask") {
                filter.inputImage = fgrImage
                filter.backgroundImage = background
                filter.maskImage = alphaImage
            }
        } else {
            filter.inputImage = fgrImage
            filter.backgroundImage = background
            filter.maskImage = alphaImage
        }

        let output = profiler?.measure("ci.output_crop") {
            filter.outputImage?.cropped(to: fgrImage.extent) ?? fgrImage
        } ?? (filter.outputImage?.cropped(to: fgrImage.extent) ?? fgrImage)
        let rendered = profiler?.measure("ci.render_create_cgimage") {
            renderContext.createCGImage(output, from: output.extent, format: .RGBA8, colorSpace: rgbColorSpace)
        } ?? renderContext.createCGImage(output, from: output.extent, format: .RGBA8, colorSpace: rgbColorSpace)
        let image = rendered ?? (profiler?.measure("ci.placeholder") {
            placeholderImage(width: Int(output.extent.width), height: Int(output.extent.height))
        } ?? placeholderImage(width: Int(output.extent.width), height: Int(output.extent.height)))
        return (image, (CACurrentMediaTime() - start) * 1000.0)
    }

    func render(pixelBuffer: CVPixelBuffer, mode: PreviewMode, profiler: FrameProfiler?) -> (image: CGImage, compositeMs: Double) {
        let start = CACurrentMediaTime()
        let source = profiler?.measure("ci.wrap_source") {
            CIImage(cvPixelBuffer: pixelBuffer, options: [.colorSpace: rgbColorSpace])
        } ?? CIImage(cvPixelBuffer: pixelBuffer, options: [.colorSpace: rgbColorSpace])
        let output: CIImage

        if mode == .alpha {
            let colorFilter = CIFilter.falseColor()
            output = profiler?.measure("ci.configure_false_color") {
                colorFilter.inputImage = source
                colorFilter.color0 = CIColor(red: 0, green: 0, blue: 0)
                colorFilter.color1 = CIColor(red: 1, green: 1, blue: 1)
                return (colorFilter.outputImage ?? source).cropped(to: source.extent)
            } ?? {
                colorFilter.inputImage = source
                colorFilter.color0 = CIColor(red: 0, green: 0, blue: 0)
                colorFilter.color1 = CIColor(red: 1, green: 1, blue: 1)
                return (colorFilter.outputImage ?? source).cropped(to: source.extent)
            }()
        } else {
            output = source
        }

        let rendered = profiler?.measure("ci.render_create_cgimage") {
            renderContext.createCGImage(output, from: output.extent, format: .RGBA8, colorSpace: rgbColorSpace)
        } ?? renderContext.createCGImage(output, from: output.extent, format: .RGBA8, colorSpace: rgbColorSpace)
        let image = rendered ?? (profiler?.measure("ci.placeholder") {
            placeholderImage(width: Int(output.extent.width), height: Int(output.extent.height))
        } ?? placeholderImage(width: Int(output.extent.width), height: Int(output.extent.height)))
        return (image, (CACurrentMediaTime() - start) * 1000.0)
    }

    private func backgroundImage(extent: CGRect) -> CIImage {
        switch backgroundMode {
        case .green:
            return CIImage(color: CIColor(red: 0, green: 1, blue: 0)).cropped(to: extent)
        case .checkerboard:
            let filter = CIFilter.checkerboardGenerator()
            filter.color0 = CIColor(red: 0.86, green: 0.86, blue: 0.86)
            filter.color1 = CIColor(red: 0.62, green: 0.62, blue: 0.62)
            filter.width = 40
            filter.center = CGPoint(x: extent.midX, y: extent.midY)
            return (filter.outputImage ?? CIImage(color: .gray)).cropped(to: extent)
        }
    }

    private func placeholderImage(width: Int, height: Int) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext(
            data: nil,
            width: max(width, 1),
            height: max(height, 1),
            bitsPerComponent: 8,
            bytesPerRow: max(width, 1) * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )!
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: max(width, 1), height: max(height, 1)))
        return context.makeImage()!
    }
}
