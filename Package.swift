// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "TLS",
    products: [
        .library(
            name: "TLS",
            targets: ["TLS"])
    ],
    dependencies: [
        .package(name: "Platform"),
        .package(name: "Crypto"),
        .package(name: "Stream"),
        .package(name: "Test")
    ],
    targets: [
        .target(
            name: "TLS",
            dependencies: ["Platform", "Crypto", "Stream"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])
            ]),
    ]
)

// MARK: - tests

testTarget("TLS") { test in
    test("Alert")
    test("Certificate")
    test("CertificateStatus")
    test("ChangeCipherSpec")
    test("ClientHello")
    test("ClientKeyExchange")
    test("ExtensionECPointFormats")
    test("ExtensionHeartbeat")
    test("ExtensionRenegotiationInfo")
    test("ExtensionServerName")
    test("ExtensionSessionTicket")
    test("ExtensionSignatureAlgorithms")
    test("ExtensionStatusRequest")
    test("ExtensionSupportedGroups")
    test("Handshake")
    test("Heartbeat")
    test("NewSessionTicket")
    test("Random")
    test("RecordLayer")
    test("ServerHello")
    test("ServerHelloDone")
    test("ServerKeyExchange")
    test("Version")
}

func testTarget(_ target: String, task: ((String) -> Void) -> Void) {
    task { test in addTest(target: target, name: test) }
}

func addTest(target: String, name: String) {
    package.targets.append(
        .executableTarget(
            name: "Tests/\(target)/\(name)",
            dependencies: ["TLS", "Test"],
            path: "Tests/\(target)/\(name)",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])
            ]))
}

// MARK: - custom package source

#if canImport(ObjectiveC)
import Darwin.C
#else
import Glibc
#endif

extension Package.Dependency {
    enum Source: String {
        case local, remote, github

        static var `default`: Self { .local }

        var baseUrl: String {
            switch self {
            case .local: return "../"
            case .remote: return "https://swiftstack.io/"
            case .github: return "https://github.com/swift-stack/"
            }
        }

        func url(for name: String) -> String {
            return self == .local
                ? baseUrl + name.lowercased()
                : baseUrl + name.lowercased() + ".git"
        }
    }

    static func package(name: String) -> Package.Dependency {
        guard let pointer = getenv("SWIFTSTACK") else {
            return .package(name: name, source: .default)
        }
        guard let source = Source(rawValue: String(cString: pointer)) else {
            fatalError("Invalid source. Use local, remote or github")
        }
        return .package(name: name, source: source)
    }

    static func package(name: String, source: Source) -> Package.Dependency {
        return source == .local
            ? .package(name: name, path: source.url(for: name))
            : .package(name: name, url: source.url(for: name), .branch("dev"))
    }
}
