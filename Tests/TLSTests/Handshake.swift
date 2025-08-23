import Testing
@testable import TLS

private let bytes: [UInt8] = [0x14, 0x00, 0x00, 0x00]

@Test
func `decode handshake finished`() async throws {
    let handshake = try await Handshake.decode(from: bytes)
    #expect(handshake == .finished(.init(hmac: [])))
}

@Test
func `encode handshake finished`() async throws {
    let result = try await Handshake.finished(.init(hmac: [])).encode()
    #expect(result == bytes)
}
