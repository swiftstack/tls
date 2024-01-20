import Test
@testable import TLS

typealias SignatureAlgorithms = Extension.SignatureAlgorithms

let algorithms: SignatureAlgorithms = [
    .ecdsa_secp521r1_sha512,
    .ecdsa_secp384r1_sha384,
    .ecdsa_secp256r1_sha256,
    .ed25519,
]

let algorithmsBytes: [UInt8] = [
    // length
    0x00, 0x08,
    // algorithms
    0x06, 0x03, 0x05, 0x03, 0x04, 0x03, 0x08, 0x07]

let algorithmsExtensionBytes: [UInt8] =
    [0x00, 0x0d, 0x00, 0x0a] + algorithmsBytes

test("decode signature_algorithms") {
    let result = try await SignatureAlgorithms.decode(from: algorithmsBytes)
    expect(result == algorithms)
}

test("decode signature_algorithms extension") {
    let result = try await ClientHello.Extension.decode(from: algorithmsExtensionBytes)
    expect(result == .signatureAlgorithms(algorithms))
}

test("encode signature_algorithms") {
    let result = try await algorithms.encode()
    expect(result == algorithmsBytes)
}

test("encode signature_algorithms extension") {
    let algorithmsExtension = ClientHello.Extension.signatureAlgorithms(algorithms)
    let result = try await algorithmsExtension.encode()
    expect(result == algorithmsExtensionBytes)
}

await run()
