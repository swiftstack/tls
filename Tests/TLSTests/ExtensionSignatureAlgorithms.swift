import Testing
@testable import TLS

private typealias SignatureAlgorithms = Extension.SignatureAlgorithms

private let algorithms: SignatureAlgorithms = [
    .ecdsa_secp521r1_sha512,
    .ecdsa_secp384r1_sha384,
    .ecdsa_secp256r1_sha256,
    .ed25519,
]

private let algorithmsBytes: [UInt8] = [
    // length
    0x00, 0x08,
    // algorithms
    0x06, 0x03, 0x05, 0x03, 0x04, 0x03, 0x08, 0x07]

private let algorithmsExtensionBytes: [UInt8] =
    [0x00, 0x0d, 0x00, 0x0a] + algorithmsBytes

@Test
func `decode signature_algorithms`() async throws {
    let result = try await SignatureAlgorithms.decode(from: algorithmsBytes)
    #expect(result == algorithms)
}

@Test
func `decode signature_algorithms extension`() async throws {
    let result = try await ClientHello.Extension
        .decode(from: algorithmsExtensionBytes)
    #expect(result == .signatureAlgorithms(algorithms))
}

@Test
func `encode signature_algorithms`() async throws {
    let result = try await algorithms.encode()
    #expect(result == algorithmsBytes)
}

@Test
func `encode signature_algorithms extension`() async throws {
    let algorithmsExtension = ClientHello.Extension
        .signatureAlgorithms(algorithms)
    let result = try await algorithmsExtension.encode()
    #expect(result == algorithmsExtensionBytes)
}
