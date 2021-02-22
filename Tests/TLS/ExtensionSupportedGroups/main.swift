import Test
@testable import TLS

typealias SupportedGroups = Extension.SupportedGroups

let groups: SupportedGroups = [
    .secp256r1, .secp521r1, .secp384r1, .x25519, .x448
]

let groupsBytes: [UInt8] = [
    // length
    0x00, 0x0a,
    // named groups
    0x00, 0x17, 0x00, 0x19, 0x00, 0x18, 0x00, 0x1d, 0x00, 0x1e
]

let groupsExtensionBytes: [UInt8] =
    [0x00, 0x0a, 0x00, 0x0c] + groupsBytes

test.case("decode named groups") {
    let result = try await SupportedGroups.decode(from: groupsBytes)
    expect(result == groups)
}

test.case("decode named groups extension") {
    let result = try await ClientHello.Extension.decode(from: groupsExtensionBytes)
    expect(result == .supportedGroups(groups))
}

test.case("encode named groups") {
    let result = try await groups.encode()
    expect(result == groupsBytes)
}

test.case("encode named groups extension") {
    let supportedGroupsExtension = ClientHello.Extension.supportedGroups(groups)
    let result = try await supportedGroupsExtension.encode()
    expect(result == groupsExtensionBytes)
}

test.run()
