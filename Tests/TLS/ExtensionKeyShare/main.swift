import Test
@testable import TLS

let key: PublicKey = [
    0xe1, 0xc7, 0x66, 0x42, 0xb6, 0x44,
    0xd1, 0xf0, 0x8b, 0x90, 0x35, 0xce, 0xf7, 0xe3,
    0x8e, 0xbb, 0x3b, 0x96, 0xfe, 0x7e, 0x4f, 0xd1,
    0xc2, 0xbb, 0x72, 0x91, 0x85, 0x89, 0x42, 0xd6,
    0xb3, 0x49]

let bytes: [UInt8] =
    [0x00, 0x24, 0x00, 0x1d, 0x00, 0x20] + key.bytes

let extensionBytes: [UInt8] =
    [0x00, 0x33, 0x00, 0x26] + bytes

test.case("decode key_share") {
    let result = try await Extension.KeysShare.decode(from: bytes)
    expect(result == [.init(group: .x25519, keyExchange: key)])
}

test.case("decode key_share extension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .keyShare([.init(group: .x25519, keyExchange: key)]))
}

test.case("encode key_share") {
    let keyShare = Extension.KeysShare([.init(group: .x25519, keyExchange: key)])
    let result = try await keyShare.encode()
    expect(result == bytes)
}

test.case("encode key_share extension") {
    let keyShare = ClientHello.Extension.keyShare([.init(group: .x25519, keyExchange: key)])
    let result = try await keyShare.encode()
    expect(result == extensionBytes)
}

test.run()
