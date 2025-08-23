import Testing
@testable import TLS

private typealias PostHandshakeAuth = Extension.PostHandshakeAuth

private let value = PostHandshakeAuth()
private let bytes: [UInt8] = [0x00, 0x31, 0x00, 0x00]

@Test
func `decode post_handshake_auth extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: bytes)
    #expect(result == .postHandshakeAuth(value))
}

@Test
func `encode post_handshake_auth extension`() async throws {
    let phaExtension = ClientHello.Extension.postHandshakeAuth(value)
    let result = try await phaExtension.encode()
    #expect(result == bytes)
}
