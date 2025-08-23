import Testing
@testable import TLS

private let bytes: [UInt8] = [0x08, 0x00, 0x00, 0x02, 0x00, 0x00]
private let encryptedExtensions: Handshake = .encryptedExtensions(.init([]))

@Test
func `decode encrypted extensions`() async throws {
    let result = try await Handshake.decode(from: bytes)
    #expect(result == encryptedExtensions)
}

@Test
func `encode encrypted extensions`() async throws {
    let result = try await encryptedExtensions.encode()
    #expect(result == bytes)
}
