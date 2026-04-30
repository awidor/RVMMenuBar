import AppKit

final class PreviewWindowController: NSWindowController {
    private let previewView = PreviewView(frame: NSRect(x: 0, y: 0, width: 1280, height: 720))

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "RVM Preview"
        window.contentView = previewView
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func show() {
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func display(_ frame: ProcessedFrame) {
        previewView.profiler = frame.profiler
        previewView.image = frame.image
        previewView.timing = frame.timing
        previewView.displayIfNeeded()
    }
}

final class PreviewView: NSView {
    var image: CGImage? {
        didSet { needsDisplay = true }
    }

    var timing: FrameTiming = .zero {
        didSet { needsDisplay = true }
    }

    weak var profiler: FrameProfiler?

    override var isFlipped: Bool {
        true
    }

    override func draw(_ dirtyRect: NSRect) {
        let drawToken = profiler?.begin("ui.preview_draw")
        defer {
            if let drawToken {
                profiler?.end(drawToken)
            }
        }

        NSColor.black.setFill()
        dirtyRect.fill()

        guard let image else {
            drawOverlay("Waiting for frames")
            return
        }

        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
        let bounds = bounds
        let imageSize = CGSize(width: image.width, height: image.height)
        let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let drawRect = CGRect(
            x: bounds.midX - drawSize.width / 2,
            y: bounds.midY - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )

        cgContext.saveGState()
        cgContext.translateBy(x: 0, y: bounds.height)
        cgContext.scaleBy(x: 1, y: -1)
        let flippedRect = CGRect(x: drawRect.minX, y: bounds.height - drawRect.maxY, width: drawRect.width, height: drawRect.height)
        cgContext.draw(image, in: flippedRect)
        cgContext.restoreGState()

        drawOverlay(timing.overlay)
    }

    private func drawOverlay(_ text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.yellow,
            .backgroundColor: NSColor.black.withAlphaComponent(0.55)
        ]
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        for (index, line) in lines.enumerated() {
            NSString(string: String(line)).draw(at: CGPoint(x: 12, y: 12 + CGFloat(index * 18)), withAttributes: attributes)
        }
    }
}
