import Testing
@testable import TLS

private let bytes: [UInt8] = [
    0x16, 0x03, 0x03, 0x00, 0x04, 0x0e, 0x00, 0x00, 0x00
]

@Test
func `decode server hello done`() async throws {
    let record = try await Record.decode(from: bytes)
    #expect(record.version == .tls12)
    #expect(record.content == .handshake(.obsolete(.serverHelloDone)))
}

@Test
func `encode server hello done`() async throws {
    let record = Record(
        version: .tls12,
        content: .handshake(.obsolete(.serverHelloDone)))
    let result = try await record.encode()
    #expect(result == bytes)
}
