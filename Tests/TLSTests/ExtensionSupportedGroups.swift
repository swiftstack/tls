import Testing
@testable import TLS

private typealias SupportedGroups = Extension.SupportedGroups

private let groups: SupportedGroups = [
    .secp256r1, .secp521r1, .secp384r1, .x25519, .x448
]

private let bytes: [UInt8] = [
    // length
    0x00, 0x0a,
    // named groups
    0x00, 0x17, 0x00, 0x19, 0x00, 0x18, 0x00, 0x1d, 0x00, 0x1e
]

private let extensionBytes: [UInt8] = [0x00, 0x0a, 0x00, 0x0c] + bytes

@Test
func `decode named groups`() async throws {
    let result = try await SupportedGroups.decode(from: bytes)
    #expect(result == groups)
}

@Test
func `decode named groups extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    #expect(result == .supportedGroups(groups))
}

@Test
func `encode named groups`() async throws {
    let result = try await groups.encode()
    #expect(result == bytes)
}

@Test
func `encode named groups extension`() async throws {
    let supportedGroups = ClientHello.Extension.supportedGroups(groups)
    let result = try await supportedGroups.encode()
    #expect(result == extensionBytes)
}
