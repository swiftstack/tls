import Test
@testable import TLS

let bytes: [UInt8] = [
    // application data
    0x17,
    // version 1.2
    0x03, 0x03,
    // length
    0x00, 0x02,
    // data
    0x04, 0x02]

test.case("decode record layer") {
    let recordLayer = try await RecordLayer.decode(from: bytes)
    expect(recordLayer.content == .applicationData([0x04, 0x02]))
}

test.case("encode record layer") {
    let recordLayer = RecordLayer(
        version: .tls12,
        content: .applicationData([0x04, 0x02]))
    let result = try await recordLayer.encode()
    expect(result == bytes)
}

test.run()
