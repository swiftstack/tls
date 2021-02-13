import Test
@testable import TLS

let bytes: [UInt8] = [
    // TLS 1.2
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

test.case("Decode") {
    let hello = try await ServerHello.decode(from: bytes)

    expect(hello.version == .tls12)
    expect(hello.random.time == 3521681308)
    expect(hello.random.bytes == [
        0x71, 0x3c, 0x8b, 0x1e,
        0xf3, 0x63, 0x8a, 0xa1, 0x92, 0xde, 0x9d, 0xcd,
        0x7b, 0x85, 0xb2, 0x0f, 0x9e, 0xc1, 0x85, 0x4c,
        0x20, 0xbb, 0xe9, 0x9e, 0x44, 0xad, 0xf6, 0x25])
    expect(hello.sessionId == .init(data: []))
    expect(hello.ciperSuite == .tls_ecdhe_rsa_with_aes_128_gcm_sha256)
    expect(hello.compressionMethod == .none)

    expect(hello.extensions.count == 6)

    expect(
        hello.extensions[safe: 0]
        ==
        .serverName([]))

    expect(
        hello.extensions[safe: 1]
        ==
        .renegotiationInfo(.init(renegotiatedConnection: [])))

    expect(
        hello.extensions[safe: 2]
        ==
        .ecPointFormats([
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2]))

    expect(
        hello.extensions[safe: 3]
        ==
        .sessionTicket(.init(data: [])))

    expect(
        hello.extensions[safe: 4]
        ==
        .statusRequest(.none))

    expect(
        hello.extensions[safe: 5]
        ==
        .heartbeat(.init(mode: .allowed)))
}

test.case("Encode") {
    let hello = ServerHello(
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
        ])

    let result = try await hello.encode()
    expect(result == bytes)

    // TLS 1.2
    guard result.count >= 2 else { return }
    expect(result[..<2] == bytes[..<2])
    // time + random
    guard result.count >= 34 else { return }
    expect(result[..<34] == bytes[..<34])
    // session id length
    guard result.count >= 35 else { return }
    expect(result[34..<35] == bytes[34..<35])
    // chiper suite
    guard result.count >= 37 else { return }
    expect(result[35..<37] == bytes[35..<37])
    // compression method
    guard result.count >= 38 else { return }
    expect(result[37..<38] == bytes[37..<38])
    // extension length
    guard result.count >= 40 else { return }
    expect(result[38..<40] == bytes[38..<40])
    // server name
    guard result.count >= 44 else { return }
    expect(result[40..<44] == bytes[40..<44])
    // renegatiation info
    guard result.count >= 49 else { return }
    expect(result[44..<49] == bytes[44..<49])
    // ec point formats
    guard result.count >= 57 else { return }
    expect(result[49..<57] == bytes[49..<57])
    // session ticket tls
    guard result.count >= 61 else { return }
    expect(result[57..<61] == bytes[57..<61])
    // status request
    guard result.count >= 65 else { return }
    expect(result[61..<65] == bytes[61..<65])
    // heartbeat
    guard result.count >= 70 else { return }
    expect(result[65..<70] == bytes[65..<70])
}

test.run()