import AppKit
import Foundation

let configuration: AppConfiguration
do {
    configuration = try AppConfiguration.parse(arguments: CommandLine.arguments)
} catch let request as CommandLineRequest {
    switch request {
    case .help:
        print(request.description)
        exit(0)
    case .error:
        fputs(request.description + "\n", stderr)
        exit(2)
    }
} catch {
    fputs(error.localizedDescription + "\n", stderr)
    exit(2)
}

let app = NSApplication.shared
let delegate = AppDelegate(configuration: configuration)

app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
