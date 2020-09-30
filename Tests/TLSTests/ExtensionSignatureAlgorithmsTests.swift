import Test
@testable import TLS

class ExtensionSignatureAlgorithmsTests: TestCase {
    typealias SignatureAlgorithms = Extension.SignatureAlgorithms

    var algorithms: SignatureAlgorithms {[
        .init(hash: .sha512, signature: .rsa),
        .init(hash: .sha512, signature: .dsa),
        .init(hash: .sha512, signature: .ecdsa),
        .init(hash: .sha384, signature: .rsa),
        .init(hash: .sha384, signature: .dsa),
        .init(hash: .sha384, signature: .ecdsa),
        .init(hash: .sha256, signature: .rsa),
        .init(hash: .sha256, signature: .dsa),
        .init(hash: .sha256, signature: .ecdsa),
        .init(hash: .sha224, signature: .rsa),
        .init(hash: .sha224, signature: .dsa),
        .init(hash: .sha224, signature: .ecdsa),
        .init(hash: .sha1, signature: .rsa),
        .init(hash: .sha1, signature: .dsa),
        .init(hash: .sha1, signature: .ecdsa),
    ]}

    var algorithmsBytes: [UInt8] {[
        0x00, 0x1e, 0x06, 0x01, 0x06, 0x02, 0x06, 0x03,
        0x05, 0x01, 0x05, 0x02, 0x05, 0x03, 0x04, 0x01,
        0x04, 0x02, 0x04, 0x03, 0x03, 0x01, 0x03, 0x02,
        0x03, 0x03, 0x02, 0x01, 0x02, 0x02, 0x02, 0x03
    ]}

    var algorithmsExtensionBytes: [UInt8] {
        [0x00, 0x0d, 0x00, 0x20] + algorithmsBytes
    }

    func testDecode() throws {
        let result = try SignatureAlgorithms(algorithmsBytes)
        expect(result == algorithms)
    }

    func testDecodeExtension() throws {
        let result = try Extension(algorithmsExtensionBytes)
        expect(result == .signatureAlgorithms(algorithms))
    }

    func testEncode() throws {
        let result = try algorithms.encode()
        expect(result == algorithmsBytes)
    }

    func testEncodeExtension() throws {
        let algorithmsExtension = Extension.signatureAlgorithms(algorithms)
        let result = try algorithmsExtension.encode()
        expect(result == algorithmsExtensionBytes)
    }
}
