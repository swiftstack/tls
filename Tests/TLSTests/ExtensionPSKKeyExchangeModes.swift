import Testing
@testable import TLS

private typealias PSKKeyExchangeModes = Extension.PSKKeyExchangeModes

private let modes: PSKKeyExchangeModes = [.psk_dhe_ke]
private let modesBytes: [UInt8] = [0x01, 0x01]
private let modesExtensionBytes: [UInt8] = [0x00, 0x2d, 0x00, 0x02] + modesBytes

@Test
func `decode psk_key_exchange_modes`() async throws {
    let result = try await PSKKeyExchangeModes.decode(from: modesBytes)
    #expect(result == modes)
}
@Test
func `decode psk_key_exchange_modes extension`() async throws {
    let result = try await ClientHello.Extension
        .decode(from: modesExtensionBytes)
    #expect(result == .pskKeyExchangeModes(modes))
}
@Test
func `encode psk_key_exchange_modes`() async throws {
    let result = try await modes.encode()
    #expect(result == modesBytes)
}
@Test
func `encode psk_key_exchange_modes extension`() async throws {
    let pskKeyExchangeModesExtension = ClientHello.Extension
        .pskKeyExchangeModes(modes)
    let result = try await pskKeyExchangeModesExtension.encode()
    #expect(result == modesExtensionBytes)
}
