import Test
@testable import TLS

typealias SupportedGroups = Extension.SupportedGroups

let groups: SupportedGroups = [
    .secp256r1,
    .secp521r1,
    .brainpoolP512r1,
    .brainpoolP384r1,
    .secp384r1,
    .brainpoolP256r1,
    .secp256k1,
    .sect571r1,
    .sect571k1,
    .sect409k1,
    .sect409r1,
    .sect283k1,
    .sect283r1
]

let groupsBytes: [UInt8] = [
    0x00, 0x1a, 0x00, 0x17, 0x00, 0x19, 0x00, 0x1c,
    0x00, 0x1b, 0x00, 0x18, 0x00, 0x1a, 0x00, 0x16,
    0x00, 0x0e, 0x00, 0x0d, 0x00, 0x0b, 0x00, 0x0c,
    0x00, 0x09, 0x00, 0x0a
]

let groupsExtensionBytes: [UInt8] =
    [0x00, 0x0a, 0x00, 0x1c] + groupsBytes

test.case("Decode") {
    let result = try await SupportedGroups.decode(from: groupsBytes)
    expect(result == groups)
}

test.case("DecodeExtension") {
    let result = try await Extension.decode(from: groupsExtensionBytes)
    expect(result == .supportedGroups(groups))
}

test.case("Encode") {
    let result = try await groups.encode()
    expect(result == groupsBytes)
}

test.case("EncodeExtension") {
    let supportedGroupsExtension = Extension.supportedGroups(groups)
    let result = try await supportedGroupsExtension.encode()
    expect(result == groupsExtensionBytes)
}

test.run()
