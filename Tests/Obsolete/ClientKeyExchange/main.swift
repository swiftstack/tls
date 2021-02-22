import Test
@testable import TLS

let bytes: [UInt8] = [
    // handshake
    0x16,
    // version
    0x03, 0x03,
    // length: 70
    0x00, 0x46,
    // client key exchange
    0x10,
    // length: 66
    0x00, 0x00, 0x42,
    // pubkey length: 65
    0x41,
    // pubkey
    0x04, 0xa0, 0xb3, 0x96, 0xc7, 0x98,
    0xfa, 0x18, 0xf8, 0x6e, 0xee, 0xa8, 0xfe, 0x8d,
    0x2d, 0x9a, 0xb6, 0xad, 0xe0, 0xd3, 0x63, 0x7d,
    0x09, 0x2c, 0x03, 0x70, 0x23, 0xb3, 0xc9, 0x76,
    0x51, 0x60, 0x6a, 0x01, 0xdb, 0x9a, 0x3c, 0x4a,
    0x19, 0x2d, 0x49, 0x3d, 0x20, 0xaa, 0x58, 0xc9,
    0x70, 0x03, 0xee, 0x21, 0x13, 0x71, 0xea, 0xc4,
    0xe9, 0x74, 0xd2, 0x37, 0xa1, 0xca, 0x59, 0xcc,
    0x98, 0xa0, 0x3e
]

let clientKeyExchange: ClientKeyExchange = .init(pubkey: [UInt8](bytes[10...]))

test.case("Decode") {
    let result = try await ClientKeyExchange.decode(from: [UInt8](bytes[9...]))
    expect(result == clientKeyExchange)
}

test.case("DecodeHandshake") {
    let record = try await RecordLayer.decode(from: bytes)
    expect(record.version == .tls12)
    expect(record.content == .handshake(
        .obsolete(.clientKeyExchange(clientKeyExchange))))
}

test.case("Encode") {
    let result = try await clientKeyExchange.encode()
    expect(result[...] == bytes[9...])
}

test.case("EncodeHandshake") {
    let record = RecordLayer(
        version: .tls12,
        content: .handshake(.obsolete(.clientKeyExchange(clientKeyExchange))))
    let result = try await record.encode()
    expect(result == bytes)
}

test.run()
