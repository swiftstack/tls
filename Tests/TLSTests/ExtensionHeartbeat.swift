import Testing
@testable import TLS

private let bytes: [UInt8] = [0x01]
private let extensionBytes: [UInt8] = [0x00, 0x0f, 0x00, 0x01] + bytes

@Test
func `decode extension heartbeat`() async throws {
    let result = try await Extension.Heartbeat.decode(from: bytes)
    #expect(result == .init(mode: .allowed))
}

@Test
func `decode extension heartbeat extension`() async throws {
    let result = try await Extension.Encrypted.decode(from: extensionBytes)
    #expect(result == .heartbeat(.init(mode: .allowed)))
}

@Test
func `encode extension heartbeat`() async throws {
    let heartbeat = Extension.Heartbeat(mode: .allowed)
    let result = try await heartbeat.encode()
    #expect(result == bytes)
}

@Test
func `encode extension heartbeat extension`() async throws {
    let heartbeat = Extension.Encrypted.heartbeat(.init(mode: .allowed))
    let result = try await heartbeat.encode()
    #expect(result == extensionBytes)
}
