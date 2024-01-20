import Test
@testable import TLS

let bytes: [UInt8] = [
    // handshake
    0x16,
    // tls 1.2
    0x03, 0x03,
    // length: 14
    0x00, 0x0e,
    // handshake type: certificate
    0x0b,
    // length: 10
    0x00, 0x00, 0x0a,
    // request context
    0x00,
    // certificates length: 6
    0x00, 0x00, 0x06,
    // certificate length: 1
    0x00, 0x00, 0x01,
    // certificate
    0x42,
    // extensions length: 0
    0x00, 0x00
]

let value: Certificates = .init(
    context: 0,
    sertificates: [.init(bytes: [0x42], extensions: [])])

let record: Record = .init(
    version: .tls12,
    content: .handshake(.certificate(value)))

test("decode handshake certificates") {
    let result = try await Record.decode(from: bytes)
    expect(result == record)
}

test("encode handshake certificates") {
    let result = try await record.encode()
    expect(result == bytes)
}

await run()
