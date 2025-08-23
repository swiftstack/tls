import Testing
@testable import TLS

private typealias SupportedVersions = Extension.SupportedVersions

private let versions: SupportedVersions = [
    .tls13
]

private let versionsBytes: [UInt8] = [0x02, 0x03, 0x04]

private let versionsExtensionBytes: [UInt8] =
    [0x00, 0x2b, 0x00, 0x03] + versionsBytes

@Test
func `decode supported versions`() async throws {
    let result = try await SupportedVersions.decode(from: versionsBytes)
    #expect(result == versions)
}

@Test
func `decode supported versions extension`() async throws {
    let result = try await ClientHello.Extension
        .decode(from: versionsExtensionBytes)
    #expect(result == .supportedVersions(versions))
}

@Test
func `encode supported versions`() async throws {
    let result = try await versions.encode()
    #expect(result == versionsBytes)
}

@Test
func `encode supported versions extension`() async throws {
    let supportedVersionsExtension = ClientHello.Extension
        .supportedVersions(versions)
    let result = try await supportedVersionsExtension.encode()
    #expect(result == versionsExtensionBytes)
}
