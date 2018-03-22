import Test
import Stream
@testable import TLS

class ExtensionSignatureAlgorithmsTests: TestCase {
    let expectedSignatures: [Extension.SignatureAlgorithms.Algorithm] = [
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
    ]

    func testExtensionSignatureAlgorithms() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x1e, 0x06, 0x01, 0x06, 0x02, 0x06, 0x03,
                 0x05, 0x01, 0x05, 0x02, 0x05, 0x03, 0x04, 0x01,
                 0x04, 0x02, 0x04, 0x03, 0x03, 0x01, 0x03, 0x02,
                 0x03, 0x03, 0x02, 0x01, 0x02, 0x02, 0x02, 0x03])
            let result = try Extension.SignatureAlgorithms(from: stream)
            assertEqual(result, .init(values: expectedSignatures))
        }
    }

    func testExtensionSignatureAlgorithmsType() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x0d, 0x00, 0x20,
                 0x00, 0x1e, 0x06, 0x01, 0x06, 0x02, 0x06, 0x03,
                 0x05, 0x01, 0x05, 0x02, 0x05, 0x03, 0x04, 0x01,
                 0x04, 0x02, 0x04, 0x03, 0x03, 0x01, 0x03, 0x02,
                 0x03, 0x03, 0x02, 0x01, 0x02, 0x02, 0x02, 0x03])
            let result = try Extension(from: stream)
            assertEqual(result, .signatureAlgorithms(
                .init(values: expectedSignatures)))
        }
    }
}
