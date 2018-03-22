// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TLS",
    products: [
        .library(name: "TLS", targets: ["TLS"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/stream.git",
            .branch("master")),
        .package(
            url: "https://github.com/swift-stack/test.git",
            .branch("master"))
    ],
    targets: [
        .target(name: "TLS", dependencies: ["Platform", "Stream"]),
        .testTarget(name: "TLSTests", dependencies: ["TLS", "Test"])
    ]
)
