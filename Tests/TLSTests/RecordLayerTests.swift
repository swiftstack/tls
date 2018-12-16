import Test
import Stream
@testable import TLS

class RecordLayerTests: TestCase {
    let bytes: [UInt8] = [
        // handshake
        0x16,
        // version 1.2
        0x03, 0x03,
        // length
        0x00, 0x4a,
        // handshake type: server hello
        0x02,
        // length
        0x00, 0x00, 0x46,
        // Server Hello
        // version 1.2
        0x03, 0x03,
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

            let recordLayer = try RecordLayer(from: stream)
            assertEqual(recordLayer.content, .handshake(.serverHello(.init(
                version: .tls12,
                random: .init(time: 3521681308, bytes: [
                    0x71, 0x3c, 0x8b, 0x1e,
                    0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
                    0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
                    0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25]),
                sessionId: .init(data: []),
                ciperSuite: .tls_ecdhe_rsa_with_aes_128_gcm_sha256,
                compressionMethod: .none,
                extensions: [
                    .serverName([]),
                    .renegotiationInfo(.init(renegotiatedConnection: [])),
                    .ecPointFormats([
                        .uncompressed,
                        .ansiX962_compressed_prime,
                        .ansiX962_compressed_char2]),
                    .sessionTicket(.init(data: [])),
                    .statusRequest(.none),
                    .heartbeat(.init(mode: .allowed))
                ]))))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let recordLayer = RecordLayer(
                version: .tls12,
                content: .handshake(.serverHello(.init(
                    version: .tls12,
                    random: .init(time: 3521681308, bytes: [
                        0x71, 0x3c, 0x8b, 0x1e,
                        0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
                        0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
                        0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25]),
                    sessionId: .init(data: []),
                    ciperSuite: .tls_ecdhe_rsa_with_aes_128_gcm_sha256,
                    compressionMethod: .none,
                    extensions: [
                        .serverName([]),
                        .renegotiationInfo(.init()),
                        .ecPointFormats([
                            .uncompressed,
                            .ansiX962_compressed_prime,
                            .ansiX962_compressed_char2]),
                        .sessionTicket(.init(data: [])),
                        .statusRequest(.none),
                        .heartbeat(.init(mode: .allowed))
                    ]))))
            try recordLayer.encode(to: stream)
            assertEqual(stream.bytes, bytes)

            // handshake
            guard stream.bytes.count >= 1 else { return }
            assertEqual(stream.bytes[..<1], bytes[..<1])
            // TLS 1.2
            guard stream.bytes.count >= 3 else { return }
            assertEqual(stream.bytes[1..<3], bytes[1..<3])
            // length
            guard stream.bytes.count >= 5 else { return }
            assertEqual(stream.bytes[3..<5], bytes[3..<5])
            // handshake type: server hello
            guard stream.bytes.count >= 6 else { return }
            assertEqual(stream.bytes[5..<6], bytes[5..<6])
            // length
            guard stream.bytes.count >= 9 else { return }
            assertEqual(stream.bytes[6..<9], bytes[6..<9])

            // Server Hello
            let helloBytes = [UInt8](stream.bytes[9...])
            let expectedHelloBytes = [UInt8](bytes[9...])
            // TLS 1.2
            guard helloBytes.count >= 2 else { return }
            assertEqual(helloBytes[..<2], expectedHelloBytes[..<2])
            // time + random
            guard helloBytes.count >= 34 else { return }
            assertEqual(helloBytes[..<34], expectedHelloBytes[..<34])
            // session id length
            guard helloBytes.count >= 35 else { return }
            assertEqual(helloBytes[34..<35], expectedHelloBytes[34..<35])
            // chiper suite
            guard helloBytes.count >= 37 else { return }
            assertEqual(helloBytes[35..<37], expectedHelloBytes[35..<37])
            // compression method
            guard helloBytes.count >= 38 else { return }
            assertEqual(helloBytes[37..<38], expectedHelloBytes[37..<38])
            // extension length
            guard helloBytes.count >= 40 else { return }
            assertEqual(helloBytes[38..<40], expectedHelloBytes[38..<40])
            // server name
            guard helloBytes.count >= 44 else { return }
            assertEqual(helloBytes[40..<44], expectedHelloBytes[40..<44])
            // renegatiation info
            guard helloBytes.count >= 49 else { return }
            assertEqual(helloBytes[44..<49], expectedHelloBytes[44..<49])
            // ec point formats
            guard helloBytes.count >= 57 else { return }
            assertEqual(helloBytes[49..<57], expectedHelloBytes[49..<57])
            // session ticket tls
            guard helloBytes.count >= 61 else { return }
            assertEqual(helloBytes[57..<61], expectedHelloBytes[57..<61])
            // status request
            guard helloBytes.count >= 65 else { return }
            assertEqual(helloBytes[61..<65], expectedHelloBytes[61..<65])
            // heartbeat
            guard helloBytes.count >= 70 else { return }
            assertEqual(helloBytes[65..<70], expectedHelloBytes[65..<70])
        }
    }

    func testDecodeHeartbeat() {
        scope {
            let stream = InputByteStream([0x18, 0x03, 0x01, 0x00, 0x00])
            let recordLayer = try RecordLayer(from: stream)
            assertEqual(
                recordLayer,
                .init(version: .tls10, content: .heartbeat))
        }
    }

    func testEncodeHeartbeat() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x18, 0x03, 0x01, 0x00, 0x00]
            let recordLayer = RecordLayer(version: .tls10, content: .heartbeat)
            try recordLayer.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
