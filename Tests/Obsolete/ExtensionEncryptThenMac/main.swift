import Test
@testable import TLS

typealias EncryptThenMac = Extension.EncryptThenMac

let value = EncryptThenMac()
let bytes: [UInt8] = [0x00, 0x16, 0x00, 0x00]

test.case("decode encrypt_then_mac extension") {
    let result = try await ClientHello.Extension.decode(from: bytes)
    expect(result == .obsolete(.encryptThenMac(value)))
}

test.case("encode encrypt_then_mac extension") {
    let etmExtension = Extension.Obsolete.encryptThenMac(value)
    let result = try await etmExtension.encode()
    expect(result == bytes)
}

test.run()
