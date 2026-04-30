// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "RVMMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "RVMMenuBar", targets: ["RVMMenuBar"])
    ],
    targets: [
        .executableTarget(name: "RVMMenuBar")
    ]
)
