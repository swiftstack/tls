import Test
@testable import TLS

let bytes: [UInt8] = [0x14, 0x03, 0x03, 0x00, 0x01, 0x01]

test.case("Decode") {
    let record = try await RecordLayer.decode(from: bytes)
    expect(record.version == .tls12)
    expect(record.content == .changeChiperSpec(.default))
}

test.case("Encode") {
    let record = RecordLayer(
        version: .tls12,
        content: .changeChiperSpec(.default))
    let result = try await record.encode()
    expect(result == bytes)
}

test.run()
