import Testing
@testable import TLS

private typealias EncryptThenMac = Extension.EncryptThenMac

private let value = EncryptThenMac()
private let bytes: [UInt8] = [0x00, 0x16, 0x00, 0x00]

@Test
func `decode encrypt_then_mac extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: bytes)
    #expect(result == .obsolete(.encryptThenMac(value)))
}

@Test
func `encode encrypt_then_mac extension`() async throws {
    let etmExtension = Extension.Obsolete.encryptThenMac(value)
    let result = try await etmExtension.encode()
    #expect(result == bytes)
}
