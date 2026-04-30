import CoreVideo
import Foundation

enum PixelBufferDebug {
    static func describe(_ label: String, _ pixelBuffer: CVPixelBuffer) {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let formatString = String(format: "%c%c%c%c",
                                  (format >> 24) & 0xff,
                                  (format >> 16) & 0xff,
                                  (format >> 8) & 0xff,
                                  format & 0xff)
        print("\(label): \(width)x\(height) \(formatString)")
    }
}
