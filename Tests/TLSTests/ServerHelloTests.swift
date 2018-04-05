import Test
import Stream
@testable import TLS

class ServerHelloTests: TestCase {
    @nonobjc
    let bytes: [UInt8] = [
        // time + random
        0xd1, 0xe8, 0x97, 0x9c, 0x71, 0x3c, 0x8b, 0x1e,
        0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
        0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
        0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25,
        // session id length
        0x00,
        // chiper suite
        0xc0, 0x2f,
        // compression method
        0x00,
        // extension length
        0x00, 0x1e,
        // server name
        0x00, 0x00, 0x00, 0x00,
        // renegatiation info
        0xff, 0x01, 0x00, 0x01, 0x00,
        // ec point formats
        0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02,
        // session ticket tls
        0x00, 0x23, 0x00, 0x00,
        // status request
        0x00, 0x05, 0x00, 0x00,
        // heartbeat
        0x00, 0x0f, 0x00, 0x01, 0x01]

    func testDecode() {
        scope {
            let stream = InputByteStream(bytes)

            let hello = try ServerHello(from: stream)

            assertEqual(hello.random.time, 3521681308)
            assertEqual(hello.random.bytes, [
                0x71, 0x3c, 0x8b, 0x1e,
                0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
                0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
                0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25])
            assertEqual(hello.sessionId, .init(data: []))
            assertEqual(hello.ciperSuite, .tls_ecdhe_rsa_with_aes_128_gcm_sha256)
            assertEqual(hello.compressionMethod, .none)

            assertEqual(hello.extensions.count, 6)

            assertEqual(
                hello.extensions[safe: 0],
                .serverName(.init(values: [])))

            assertEqual(
                hello.extensions[safe: 1],
                .renegotiationInfo(.init(values: [])))

            assertEqual(
                hello.extensions[safe: 2],
                .ecPointFormats(.init(values: [
                    .uncompressed,
                    .ansiX962_compressed_prime,
                    .ansiX962_compressed_char2])))

            assertEqual(
                hello.extensions[safe: 3],
                .sessionTicket(.init(data: [])))

            assertEqual(
                hello.extensions[safe: 4],
                .statusRequest(.init(certificateStatus: .none)))

            assertEqual(
                hello.extensions[safe: 5],
                .heartbeat(.init(mode: .allowed)))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()

            let hello = ServerHello(
                random: .init(time: 3521681308, bytes: [
                    0x71, 0x3c, 0x8b, 0x1e,
                    0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
                    0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
                    0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25]),
                sessionId: .init(data: []),
                ciperSuite: .tls_ecdhe_rsa_with_aes_128_gcm_sha256,
                compressionMethod: .none,
                extensions: [
                    .serverName(.init(values: [])),
                    .renegotiationInfo(.init(values: [])),
                    .ecPointFormats(.init(values: [
                        .uncompressed,
                        .ansiX962_compressed_prime,
                        .ansiX962_compressed_char2])),
                    .sessionTicket(.init(data: [])),
                    .statusRequest(.init(certificateStatus: .none)),
                    .heartbeat(.init(mode: .allowed))
                ])

            try hello.encode(to: stream)

            assertEqual(stream.bytes, bytes)

            // time + random
            guard stream.bytes.count >= 32 else { return }
            assertEqual(stream.bytes[..<32], bytes[..<32])
            // session id length
            guard stream.bytes.count >= 33 else { return }
            assertEqual(stream.bytes[32..<33], bytes[32..<33])
            // chiper suite
            guard stream.bytes.count >= 35 else { return }
            assertEqual(stream.bytes[33..<35], bytes[33..<35])
            // compression method
            guard stream.bytes.count >= 36 else { return }
            assertEqual(stream.bytes[35..<36], bytes[35..<36])
            // extension length
            guard stream.bytes.count >= 38 else { return }
            assertEqual(stream.bytes[36..<38], bytes[36..<38])
            // server name
            guard stream.bytes.count >= 46 else { return }
            assertEqual(stream.bytes[42..<46], bytes[42..<46])
            // renegatiation info
            guard stream.bytes.count >= 51 else { return }
            assertEqual(stream.bytes[46..<51], bytes[46..<51])
            // ec point formats
            guard stream.bytes.count >= 59 else { return }
            assertEqual(stream.bytes[51..<59], bytes[51..<59])
            // session ticket tls
            guard stream.bytes.count >= 63 else { return }
            assertEqual(stream.bytes[59..<63], bytes[59..<63])
            // status request
            guard stream.bytes.count >= 67 else { return }
            assertEqual(stream.bytes[63..<67], bytes[63..<67])
            // heartbeat
            guard stream.bytes.count >= 72 else { return }
            assertEqual(stream.bytes[67..<72], bytes[67..<72])
        }
    }
}
