import Test
@testable import TLS

typealias PSKKeyExchangeModes = Extension.PSKKeyExchangeModes

let modes: PSKKeyExchangeModes = [
    .psk_dhe_ke
]
let modesBytes: [UInt8] =
    [0x01, 0x01]
let modesExtensionBytes: [UInt8] =
    [0x00, 0x2d, 0x00, 0x02] + modesBytes

test("decode psk_key_exchange_modes") {
    let result = try await PSKKeyExchangeModes.decode(from: modesBytes)
    expect(result == modes)
}

test("decode psk_key_exchange_modes extension") {
    let result = try await ClientHello.Extension.decode(from: modesExtensionBytes)
    expect(result == .pskKeyExchangeModes(modes))
}

test("encode psk_key_exchange_modes") {
    let result = try await modes.encode()
    expect(result == modesBytes)
}

test("encode psk_key_exchange_modes extension") {
    let pskKeyExchangeModesExtension = ClientHello.Extension.pskKeyExchangeModes(modes)
    let result = try await pskKeyExchangeModesExtension.encode()
    expect(result == modesExtensionBytes)
}

await run()
