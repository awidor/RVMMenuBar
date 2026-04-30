import AppKit

final class StatusMenuController: NSObject {
    private let runtimeController: RuntimeController
    private let previewController: PreviewWindowController
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let stateItem = NSMenuItem(title: "Stopped", action: nil, keyEquivalent: "")
    private let timingItem = NSMenuItem(title: "0.0 FPS", action: nil, keyEquivalent: "")
    private let startStopItem = NSMenuItem(title: "Start", action: #selector(toggleRunning), keyEquivalent: "s")
    private let previewItem = NSMenuItem(title: "Show Preview", action: #selector(showPreview), keyEquivalent: "p")
    private let greenItem = NSMenuItem(title: "Green Background", action: #selector(selectGreen), keyEquivalent: "")
    private let checkerboardItem = NSMenuItem(title: "Checkerboard Background", action: #selector(selectCheckerboard), keyEquivalent: "")
    private let compositePreviewItem = NSMenuItem(title: "Preview Composite", action: #selector(selectCompositePreview), keyEquivalent: "")
    private let cameraPreviewItem = NSMenuItem(title: "Preview Raw Camera", action: #selector(selectCameraPreview), keyEquivalent: "")
    private let foregroundPreviewItem = NSMenuItem(title: "Preview Foreground", action: #selector(selectForegroundPreview), keyEquivalent: "")
    private let alphaPreviewItem = NSMenuItem(title: "Preview Alpha", action: #selector(selectAlphaPreview), keyEquivalent: "")
    private let profilingItem = NSMenuItem(title: "Profiling Debug", action: #selector(toggleProfiling), keyEquivalent: "d")

    private var currentState: RuntimeState = .stopped

    init(runtimeController: RuntimeController, previewController: PreviewWindowController) {
        self.runtimeController = runtimeController
        self.previewController = previewController
        super.init()
        configure()
    }

    func updateState(_ state: RuntimeState) {
        currentState = state
        stateItem.title = state.label
        startStopItem.title = isRunningLike(state) ? "Stop" : "Start"
        statusItem.button?.title = statusTitle(state: state, timing: timingItem.title)
    }

    func updateTiming(_ timing: FrameTiming) {
        timingItem.title = timing.summary
        statusItem.button?.title = statusTitle(state: currentState, timing: timing.summary)
    }

    func updateProfilingMode(_ isEnabled: Bool) {
        profilingItem.state = isEnabled ? .on : .off
    }

    private func configure() {
        statusItem.button?.title = "RVM"
        statusItem.button?.toolTip = "RVM CoreML Preview"

        stateItem.isEnabled = false
        timingItem.isEnabled = false
        startStopItem.target = self
        previewItem.target = self
        greenItem.target = self
        checkerboardItem.target = self
        compositePreviewItem.target = self
        cameraPreviewItem.target = self
        foregroundPreviewItem.target = self
        alphaPreviewItem.target = self
        profilingItem.target = self

        menu.addItem(stateItem)
        menu.addItem(timingItem)
        menu.addItem(.separator())
        menu.addItem(startStopItem)
        menu.addItem(previewItem)
        menu.addItem(.separator())
        menu.addItem(compositePreviewItem)
        menu.addItem(cameraPreviewItem)
        menu.addItem(foregroundPreviewItem)
        menu.addItem(alphaPreviewItem)
        menu.addItem(.separator())
        menu.addItem(greenItem)
        menu.addItem(checkerboardItem)
        menu.addItem(.separator())
        menu.addItem(profilingItem)
        menu.addItem(NSMenuItem(title: "Reset Recurrent State", action: #selector(resetState), keyEquivalent: "r"))
        menu.items.last?.target = self
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        menu.items.last?.target = self

        statusItem.menu = menu
        updateBackgroundChecks()
        updatePreviewChecks()
        updateProfilingMode(runtimeController.isProfilingEnabled)
    }

    @objc private func toggleRunning() {
        if isRunningLike(currentState) {
            runtimeController.stop()
        } else {
            runtimeController.start()
            previewController.show()
        }
    }

    @objc private func showPreview() {
        previewController.show()
    }

    @objc private func selectGreen() {
        runtimeController.backgroundMode = .green
        updateBackgroundChecks()
    }

    @objc private func selectCheckerboard() {
        runtimeController.backgroundMode = .checkerboard
        updateBackgroundChecks()
    }

    @objc private func selectCompositePreview() {
        runtimeController.previewMode = .composite
        updatePreviewChecks()
    }

    @objc private func selectCameraPreview() {
        runtimeController.previewMode = .camera
        updatePreviewChecks()
    }

    @objc private func selectForegroundPreview() {
        runtimeController.previewMode = .foreground
        updatePreviewChecks()
    }

    @objc private func selectAlphaPreview() {
        runtimeController.previewMode = .alpha
        updatePreviewChecks()
    }

    @objc private func resetState() {
        runtimeController.resetRecurrentState()
    }

    @objc private func toggleProfiling() {
        runtimeController.isProfilingEnabled.toggle()
        updateProfilingMode(runtimeController.isProfilingEnabled)
    }

    @objc private func quit() {
        runtimeController.stop()
        NSApp.terminate(nil)
    }

    private func updateBackgroundChecks() {
        greenItem.state = runtimeController.backgroundMode == .green ? .on : .off
        checkerboardItem.state = runtimeController.backgroundMode == .checkerboard ? .on : .off
    }

    private func updatePreviewChecks() {
        compositePreviewItem.state = runtimeController.previewMode == .composite ? .on : .off
        cameraPreviewItem.state = runtimeController.previewMode == .camera ? .on : .off
        foregroundPreviewItem.state = runtimeController.previewMode == .foreground ? .on : .off
        alphaPreviewItem.state = runtimeController.previewMode == .alpha ? .on : .off
    }

    private func isRunningLike(_ state: RuntimeState) -> Bool {
        switch state {
        case .starting, .running:
            return true
        case .stopped, .failed:
            return false
        }
    }

    private func statusTitle(state: RuntimeState, timing: String) -> String {
        switch state {
        case .running:
            return "RVM \(timing.components(separatedBy: " ").prefix(2).joined(separator: " "))"
        case .starting:
            return "RVM Starting"
        case .failed:
            return "RVM Error"
        case .stopped:
            return "RVM"
        }
    }
}
