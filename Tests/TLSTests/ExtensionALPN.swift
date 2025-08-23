import Testing
@testable import TLS

private typealias ALPN = Extension.ALPN

private let alpn: ALPN = [
    .http2, .http11
]

private let bytes: [UInt8] = [
    // length
    0x00, 0x0c,
    // names
    0x02, 0x68, 0x32,
    0x08, 0x68, 0x74, 0x74, 0x70, 0x2f, 0x31, 0x2e, 0x31
]

private let extensionBytes: [UInt8] =
    [0x00, 0x10, 0x00, 0x0e] + bytes

@Test
func `decode next protocol`() async throws {
    let result = try await ALPN.decode(from: bytes)
    #expect(result == alpn)
}

@Test
func `decode next protocol extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    #expect(result == .alpn(alpn))
}

@Test
func `encode next protocol`() async throws {
    let result = try await alpn.encode()
    #expect(result == bytes)
}

@Test
func `encode next protocol extension`() async throws {
    let alpnExtension = ClientHello.Extension.alpn(alpn)
    let result = try await alpnExtension.encode()
    #expect(result == extensionBytes)
}
