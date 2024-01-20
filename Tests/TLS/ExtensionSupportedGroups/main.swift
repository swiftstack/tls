import Test
@testable import TLS

typealias SupportedGroups = Extension.SupportedGroups

let groups: SupportedGroups = [
    .secp256r1, .secp521r1, .secp384r1, .x25519, .x448
]

let bytes: [UInt8] = [
    // length
    0x00, 0x0a,
    // named groups
    0x00, 0x17, 0x00, 0x19, 0x00, 0x18, 0x00, 0x1d, 0x00, 0x1e
]

let extensionBytes: [UInt8] = [0x00, 0x0a, 0x00, 0x0c] + bytes

test("decode named groups") {
    let result = try await SupportedGroups.decode(from: bytes)
    expect(result == groups)
}

test("decode named groups extension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .supportedGroups(groups))
}

test("encode named groups") {
    let result = try await groups.encode()
    expect(result == bytes)
}

test("encode named groups extension") {
    let supportedGroups = ClientHello.Extension.supportedGroups(groups)
    let result = try await supportedGroups.encode()
    expect(result == extensionBytes)
}

await run()
