import AppKit
import QuartzCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let configuration: AppConfiguration
    private var statusController: StatusMenuController?
    private var runtimeController: RuntimeController?
    private var previewController: PreviewWindowController?

    init(configuration: AppConfiguration) {
        self.configuration = configuration
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let previewController = PreviewWindowController()
        let runtimeController = RuntimeController(configuration: configuration)
        let statusController = StatusMenuController(runtimeController: runtimeController, previewController: previewController)

        runtimeController.onFrame = { [weak runtimeController, weak previewController, weak statusController] frame in
            let mainQueueStart = CACurrentMediaTime()
            DispatchQueue.main.async {
                frame.profiler?.record("main_queue.wait", startedAt: mainQueueStart)
                let displayStart = CACurrentMediaTime()
                previewController?.display(frame)
                frame.profiler?.record("ui.preview_display", startedAt: displayStart)
                let statusStart = CACurrentMediaTime()
                statusController?.updateTiming(frame.timing)
                frame.profiler?.record("ui.status_update", startedAt: statusStart)
                runtimeController?.completeFrame(frame)
            }
        }

        runtimeController.onStateChange = { [weak statusController] state in
            DispatchQueue.main.async {
                statusController?.updateState(state)
            }
        }

        runtimeController.onProfilingModeChange = { [weak statusController] isEnabled in
            DispatchQueue.main.async {
                statusController?.updateProfilingMode(isEnabled)
            }
        }

        self.previewController = previewController
        self.runtimeController = runtimeController
        self.statusController = statusController

        if configuration.autoStart {
            runtimeController.start()
            if configuration.showPreviewOnStart {
                previewController.show()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        runtimeController?.stop()
        runtimeController?.closeProfiler()
    }
}
