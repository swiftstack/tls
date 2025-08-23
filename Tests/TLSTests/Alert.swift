import Testing
@testable import TLS

private let bytes: [UInt8] = [0x01, 0x00]

@Test
func `decode alert`() async throws {
    let alert = try await Alert.decode(from: bytes)
    #expect(alert.level == .warning)
    #expect(alert.description == .closeNotify)
}

@Test
func `encode alert`() async throws {
    let alert = Alert(level: .warning, description: .closeNotify)
    let result = try await alert.encode()
    #expect(result == bytes)
}
