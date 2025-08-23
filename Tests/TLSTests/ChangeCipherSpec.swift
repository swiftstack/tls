import Testing
@testable import TLS

private let bytes: [UInt8] = [
    // content type: change cipher spec
    0x14,
    // tls version: 1.2
    0x03, 0x03,
    // length: 1
    0x00, 0x01,
    // change cipher spec message
    0x01
]

@Test
func `decode change cipher spec`() async throws {
    let record = try await Record.decode(from: bytes)
    #expect(record.version == .tls12)
    #expect(record.content == .changeChiperSpec(.default))
}

@Test
func `encode change cipher spec`() async throws {
    let record = Record(
        version: .tls12,
        content: .changeChiperSpec(.default))
    let result = try await record.encode()
    #expect(result == bytes)
}
