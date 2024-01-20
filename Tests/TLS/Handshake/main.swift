import Test
@testable import TLS

let bytes: [UInt8] = [0x14, 0x00, 0x00, 0x00]

test("decode handshake finished") {
    let handshake = try await Handshake.decode(from: bytes)
    expect(handshake == .finished(.init(hmac: [])))
}

test("encode handshake finished") {
    let result = try await Handshake.finished(.init(hmac: [])).encode()
    expect(result == bytes)
}

await run()
