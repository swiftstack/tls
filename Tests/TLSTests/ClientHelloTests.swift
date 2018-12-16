import Test
import Stream
@testable import TLS

class ClientHelloTests: TestCase {
    let bytes: [UInt8] = [
        // TLS 1.2
        0x03, 0x03,
        // time + random
        0x04, 0x5c, 0x7c, 0x69, 0xb0, 0x0f, 0x73, 0x18,
        0x56, 0xae, 0x7c, 0x3f, 0x7c, 0x19, 0x13, 0x19,
        0x6a, 0xfd, 0xd0, 0x76, 0xb6, 0x7f, 0x55, 0x74,
        0xaa, 0xd8, 0x23, 0x1d, 0x31, 0x12, 0xdc, 0x54,
        // sessionId length
        0x00,
        // ciper suites length
        0x00, 0x2c,
        // ciper suites
        0xc0, 0x2c, 0xc0, 0x2b, 0xc0, 0x24, 0xc0, 0x23,
        0xc0, 0x0a, 0xc0, 0x09, 0xc0, 0x08, 0xc0, 0x30,
        0xc0, 0x2f, 0xc0, 0x28, 0xc0, 0x27, 0xc0, 0x14,
        0xc0, 0x13, 0xc0, 0x12, 0x00, 0x9d, 0x00, 0x9c,
        0x00, 0x3d, 0x00, 0x3c, 0x00, 0x35, 0x00, 0x2f,
        0x00, 0x0a, 0x00, 0xff,
        // compression methods
        0x01, 0x00,
        // extensions length
        0x00, 0x6c,
        // server name
        0x00, 0x00, 0x00, 0x0a, 0x00, 0x08, 0x00, 0x00,
        0x05, 0x79, 0x61, 0x2e, 0x72, 0x75,
        // ec point formats
        0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02,
        // supported groups (elliptic curves)
        0x00, 0x0a, 0x00, 0x1c, 0x00, 0x1a, 0x00, 0x17,
        0x00, 0x19, 0x00, 0x1c, 0x00, 0x1b, 0x00, 0x18,
        0x00, 0x1a, 0x00, 0x16, 0x00, 0x0e, 0x00, 0x0d,
        0x00, 0x0b, 0x00, 0x0c, 0x00, 0x09, 0x00, 0x0a,
        // SessionTicket TLS
        0x00, 0x23, 0x00, 0x00,
        // signature algorithms
        0x00, 0x0d, 0x00, 0x20, 0x00, 0x1e, 0x06, 0x01,
        0x06, 0x02, 0x06, 0x03, 0x05, 0x01, 0x05, 0x02,
        0x05, 0x03, 0x04, 0x01, 0x04, 0x02, 0x04, 0x03,
        0x03, 0x01, 0x03, 0x02, 0x03, 0x03, 0x02, 0x01,
        0x02, 0x02, 0x02, 0x03,
        // status request
        0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00,
        0x00,
        // heartbeat
        0x00, 0x0f, 0x00, 0x01, 0x01]

    func testDecode() {
        scope {
            let stream = InputByteStream(bytes)

            let hello = try ClientHello(from: stream)

            assertEqual(hello.random.time, 73170025)

            assertEqual(hello.random.bytes, [
                0xb0, 0x0f, 0x73, 0x18, 0x56, 0xae, 0x7c, 0x3f,
                0x7c, 0x19, 0x13, 0x19, 0x6a, 0xfd, 0xd0, 0x76,
                0xb6, 0x7f, 0x55, 0x74, 0xaa, 0xd8, 0x23, 0x1d,
                0x31, 0x12, 0xdc, 0x54
                ])

            assertEqual(hello.sessionId, .init(data: []))

            assertEqual(hello.ciperSuites, [
                .tls_ecdhe_ecdsa_with_aes_256_gcm_sha384,
                .tls_ecdhe_ecdsa_with_aes_128_gcm_sha256,
                .tls_ecdhe_ecdsa_with_aes_256_cbc_sha384,
                .tls_ecdhe_ecdsa_with_aes_128_cbc_sha256,
                .tls_ecdhe_ecdsa_with_aes_256_cbc_sha,
                .tls_ecdhe_ecdsa_with_aes_128_cbc_sha,
                .tls_ecdhe_ecdsa_with_3des_ede_cbc_sha,
                .tls_ecdhe_rsa_with_aes_256_gcm_sha384,
                .tls_ecdhe_rsa_with_aes_128_gcm_sha256,
                .tls_ecdhe_rsa_with_aes_256_cbc_sha384,
                .tls_ecdhe_rsa_with_aes_128_cbc_sha256,
                .tls_ecdhe_rsa_with_aes_256_cbc_sha,
                .tls_ecdhe_rsa_with_aes_128_cbc_sha,
                .tls_ecdhe_rsa_with_3des_ede_cbc_sha,
                .tls_rsa_with_aes_256_gcm_sha384,
                .tls_rsa_with_aes_128_gcm_sha256,
                .tls_rsa_with_aes_256_cbc_sha256,
                .tls_rsa_with_aes_128_cbc_sha256,
                .tls_rsa_with_aes_256_cbc_sha,
                .tls_rsa_with_aes_128_cbc_sha,
                .tls_rsa_with_3des_ede_cbc_sha,
                .tls_empty_renegotiation_info_scsv
                ])

            assertEqual(hello.compressionMethods, [.none])

            assertEqual(hello.extensions.count, 7)

            assertEqual(
                hello.extensions[safe: 0],
                .serverName([.init(type: .hostName, value: "ya.ru")]))

            assertEqual(
                hello.extensions[safe: 1],
                .ecPointFormats([
                    .uncompressed,
                    .ansiX962_compressed_prime,
                    .ansiX962_compressed_char2]))

            assertEqual(
                hello.extensions[safe: 2],
                .supportedGroups([
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
                    .sect283r1]))

            assertEqual(
                hello.extensions[safe: 3],
                .sessionTicket(.init(data: [])))

            assertEqual(
                hello.extensions[safe: 4],
                .signatureAlgorithms([
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
                ]))

            assertEqual(
                hello.extensions[safe: 5],
                .statusRequest(.ocsp(.init())))

            assertEqual(
                hello.extensions[safe: 6],
                .heartbeat(.init(mode: .allowed)))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()

            let hello = ClientHello(
                version: .tls12,
                random: .init(time: 73170025, bytes: [
                    0xb0, 0x0f, 0x73, 0x18, 0x56, 0xae, 0x7c, 0x3f,
                    0x7c, 0x19, 0x13, 0x19, 0x6a, 0xfd, 0xd0, 0x76,
                    0xb6, 0x7f, 0x55, 0x74, 0xaa, 0xd8, 0x23, 0x1d,
                    0x31, 0x12, 0xdc, 0x54
                    ]),
                sessionId: .init(data: []),
                ciperSuites: [
                    .tls_ecdhe_ecdsa_with_aes_256_gcm_sha384,
                    .tls_ecdhe_ecdsa_with_aes_128_gcm_sha256,
                    .tls_ecdhe_ecdsa_with_aes_256_cbc_sha384,
                    .tls_ecdhe_ecdsa_with_aes_128_cbc_sha256,
                    .tls_ecdhe_ecdsa_with_aes_256_cbc_sha,
                    .tls_ecdhe_ecdsa_with_aes_128_cbc_sha,
                    .tls_ecdhe_ecdsa_with_3des_ede_cbc_sha,
                    .tls_ecdhe_rsa_with_aes_256_gcm_sha384,
                    .tls_ecdhe_rsa_with_aes_128_gcm_sha256,
                    .tls_ecdhe_rsa_with_aes_256_cbc_sha384,
                    .tls_ecdhe_rsa_with_aes_128_cbc_sha256,
                    .tls_ecdhe_rsa_with_aes_256_cbc_sha,
                    .tls_ecdhe_rsa_with_aes_128_cbc_sha,
                    .tls_ecdhe_rsa_with_3des_ede_cbc_sha,
                    .tls_rsa_with_aes_256_gcm_sha384,
                    .tls_rsa_with_aes_128_gcm_sha256,
                    .tls_rsa_with_aes_256_cbc_sha256,
                    .tls_rsa_with_aes_128_cbc_sha256,
                    .tls_rsa_with_aes_256_cbc_sha,
                    .tls_rsa_with_aes_128_cbc_sha,
                    .tls_rsa_with_3des_ede_cbc_sha,
                    .tls_empty_renegotiation_info_scsv
                ],
                compressionMethods: [.none],
                extensions: [
                    .serverName([
                        .init(type: .hostName, value: "ya.ru")]),
                    .ecPointFormats([
                        .uncompressed,
                        .ansiX962_compressed_prime,
                        .ansiX962_compressed_char2]),
                    .supportedGroups([
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
                        .sect283r1]),
                    .sessionTicket(
                        .init(data: [])),
                    .signatureAlgorithms([
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
                        ]),
                    .statusRequest(.ocsp(.init())),
                    .heartbeat(.init(mode: .allowed))
                ])

            try hello.encode(to: stream)
            assertEqual(stream.bytes, bytes)

            // TLS 1.2
            guard stream.bytes.count >= 2 else { return }
            assertEqual(stream.bytes[..<2], bytes[..<2])
            // time + random
            guard stream.bytes.count >= 34 else { return }
            assertEqual(stream.bytes[2..<34], bytes[2..<34])
            // sessionId length
            guard stream.bytes.count >= 35 else { return }
            assertEqual(stream.bytes[34..<35], bytes[34..<35])
            // ciper suites length
            guard stream.bytes.count >= 37 else { return }
            assertEqual(stream.bytes[35..<37], bytes[35..<37])
            // ciper suites
            guard stream.bytes.count >= 80 else { return }
            assertEqual(stream.bytes[37..<80], bytes[37..<80])
            // compression methods
            guard stream.bytes.count >= 82 else { return }
            assertEqual(stream.bytes[80..<82], bytes[80..<82])
            // extensions length
            guard stream.bytes.count >= 84 else { return }
            assertEqual(stream.bytes[82..<84], bytes[82..<84])
            // server name
            guard stream.bytes.count >= 98 else { return }
            assertEqual(stream.bytes[84..<98], bytes[84..<98])
            // ec point formats
            guard stream.bytes.count >= 106 else { return }
            assertEqual(stream.bytes[98..<106], bytes[98..<106])
            // supported groups (elliptic curves)
            guard stream.bytes.count >= 138 else { return }
            assertEqual(stream.bytes[106..<138], bytes[106..<138])
            // SessionTicket TLS
            guard stream.bytes.count >= 142 else { return }
            assertEqual(stream.bytes[138..<142], bytes[138..<142])
            // signature algorithms
            guard stream.bytes.count >= 178 else { return }
            assertEqual(stream.bytes[142..<178], bytes[142..<178])
            // status request
            guard stream.bytes.count >= 187 else { return }
            assertEqual(stream.bytes[178..<187], bytes[178..<187])
            // heartbeat
            guard stream.bytes.count >= 192 else { return }
            assertEqual(stream.bytes[187..<192], bytes[187..<192])
        }
    }
}
