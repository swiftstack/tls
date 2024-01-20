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

test("decode record layer") {
    let recordLayer = try await Record.decode(from: bytes)
    expect(recordLayer.content == .applicationData([0x04, 0x02]))
}

test("encode record layer") {
    let recordLayer = Record(
        version: .tls12,
        content: .applicationData([0x04, 0x02]))
    let result = try await recordLayer.encode()
    expect(result == bytes)
}

await run()
