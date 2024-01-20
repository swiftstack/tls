import Test
@testable import TLS

let bytes: [UInt8] = [0x18, 0x03, 0x01, 0x00, 0x00]

test("DecodeHeartbeat") {
    let recordLayer = try await Record.decode(from: bytes)
    expect(recordLayer == .init(version: .tls10, content: .heartbeat))
}

test("EncodeHeartbeat") {
    let recordLayer = Record(version: .tls10, content: .heartbeat)
    let result = try await recordLayer.encode()
    expect(result == bytes)
}

await run()
