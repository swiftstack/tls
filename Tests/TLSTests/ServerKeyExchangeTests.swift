import Test
import Stream
@testable import TLS

class ServerKeyExchangeTests: TestCase {
    @nonobjc
    let bytes: [UInt8] = [
        // handshake
        0x16,
        // version
        0x03, 0x03,
        // length: 333
        0x01, 0x4d,
        // server key exchange
        0x0c,
        // length: 329
        0x00, 0x01, 0x49,
        // named_curve
        0x03,
        // secp256r1
        0x00, 0x17,
        // pubkey length: 65
        0x41,
        // pubkey
        0x04, 0x03, 0x14,
        0x51, 0x9e, 0xe2, 0x27, 0xcb, 0x1d, 0xad, 0x42,
        0xe6, 0x98, 0xd2, 0x3e, 0xca, 0xc0, 0xbd, 0xa4,
        0xb2, 0x7b, 0x50, 0x37, 0x40, 0x44, 0x68, 0xfe,
        0x63, 0x49, 0x77, 0x46, 0xb2, 0x26, 0x3f, 0x91,
        0xb6, 0x08, 0x0e, 0xc6, 0x79, 0x0d, 0xdd, 0x90,
        0xc2, 0x63, 0x4d, 0xa7, 0x51, 0x5d, 0x5e, 0x8c,
        0x32, 0x7c, 0x13, 0xf3, 0x23, 0x29, 0x45, 0xc8,
        0xd6, 0x3f, 0xbf, 0xa6, 0x42, 0xe8,
        // SHA512
        0x06,
        // RSA
        0x01,
        // length: 256
        0x01, 0x00,
        // signature
        0x2e, 0xd5, 0x38, 0x98, 0x5e, 0xff,
        0x8f, 0x5d, 0xd6, 0x67, 0xd2, 0xbb, 0xdf, 0x31,
        0xf5, 0x6f, 0x15, 0x07, 0xdd, 0x6c, 0x29, 0xe1,
        0x78, 0x61, 0xb4, 0xab, 0x79, 0x8e, 0xf6, 0x76,
        0x81, 0x5c, 0xf7, 0xd2, 0x4a, 0x2d, 0xd6, 0xd2,
        0x4a, 0x1f, 0x90, 0x45, 0x52, 0x19, 0x95, 0x2a,
        0xfa, 0x52, 0x77, 0x9a, 0x09, 0x7d, 0x96, 0xce,
        0x35, 0x05, 0xc9, 0xe1, 0x3c, 0x95, 0xba, 0xee,
        0x3b, 0x42, 0xac, 0xa9, 0x95, 0x9c, 0xe7, 0x9f,
        0xc6, 0xbe, 0xb1, 0xa4, 0x5e, 0x0f, 0x25, 0x5b,
        0x68, 0x88, 0xd1, 0x69, 0x84, 0x98, 0xb1, 0xdb,
        0x97, 0xba, 0x36, 0x53, 0x9c, 0xa2, 0xf3, 0x62,
        0x21, 0xb4, 0xa0, 0x40, 0x08, 0x50, 0x14, 0xea,
        0x0f, 0x72, 0xbb, 0xdc, 0x27, 0x02, 0xd9, 0xfb,
        0xae, 0x23, 0x0a, 0xaa, 0x9f, 0x5e, 0xc0, 0xf5,
        0x9e, 0x69, 0xbf, 0xde, 0x17, 0xf0, 0x4d, 0x7e,
        0xd0, 0x9a, 0xc7, 0x29, 0xde, 0x3c, 0xcb, 0x2b,
        0x8b, 0xa9, 0x8e, 0x1c, 0x0c, 0x40, 0xf0, 0xe9,
        0x62, 0xd9, 0x83, 0x7e, 0x5a, 0xde, 0x63, 0x13,
        0xd4, 0x27, 0xe4, 0x86, 0xc2, 0x7b, 0x12, 0x82,
        0x9b, 0x0e, 0x6c, 0x79, 0x27, 0xb5, 0x5b, 0xce,
        0xee, 0x45, 0x0b, 0xa1, 0xb8, 0xd2, 0x1d, 0x76,
        0x70, 0x35, 0xb0, 0x8b, 0xd0, 0xad, 0xde, 0x17,
        0x38, 0xc9, 0x58, 0x41, 0xb5, 0x82, 0xe3, 0xdd,
        0x21, 0x61, 0x7d, 0x06, 0xf4, 0xc5, 0x3c, 0x04,
        0x43, 0x6f, 0x08, 0x79, 0x35, 0xd2, 0x29, 0x8f,
        0x98, 0x9e, 0xf1, 0x32, 0x37, 0x15, 0xd0, 0x52,
        0x45, 0x06, 0x09, 0x35, 0x47, 0x67, 0xa4, 0x3f,
        0xa6, 0x6b, 0x7a, 0x4c, 0x76, 0x23, 0xe0, 0x96,
        0x73, 0x89, 0x3e, 0x26, 0xa6, 0x8f, 0x92, 0xfd,
        0x26, 0xa3, 0xe3, 0xa9, 0x41, 0x99, 0x32, 0xfa,
        0xa1, 0x3d, 0xc8, 0x25, 0x2f, 0x07, 0xbd, 0x9f,
        0x00, 0xcd
    ]

    var serverKeyExchange: ServerKeyExchange {
        return .init(
            curve: .secp256r1,
            pubkey: [UInt8](bytes[13..<78]),
            algorithm: .init(hash: .sha512, signature: .rsa),
            signature: [UInt8](bytes[82...]))
    }

    func testDecode() {
        scope {
            let stream = InputByteStream([UInt8](bytes[9...]))
            let result = try ServerKeyExchange(from: stream)
            assertEqual(result, serverKeyExchange)
        }
    }

    func testDecodeHandshake() {
        scope {
            let stream = InputByteStream(bytes)
            let record = try RecordLayer(from: stream)
            assertEqual(record.version, .tls12)
            assertEqual(record.content, .handshake(
                .serverKeyExchange(serverKeyExchange)))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            try serverKeyExchange.encode(to: stream)
            assertEqual(stream.bytes[...], bytes[9...])
        }
    }

    func testEncodeHandshake() {
        scope {
            let stream = OutputByteStream()
            let record = RecordLayer(
                version: .tls12,
                content: .handshake(.serverKeyExchange(serverKeyExchange)))
            try record.encode(to: stream)
            assertEqual(stream.bytes, bytes)
        }
    }
}
