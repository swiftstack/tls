import Test
@testable import TLS

let bytes: [UInt8] = [0x14, 0x00, 0x00, 0x00]

test.case("decode handshake finished") {
    let handshake = try await Handshake.decode(from: bytes)
    expect(handshake == .finished([]))
}

test.case("encode handshake finished") {
    let result = try await Handshake.finished([]).encode()
    expect(result == bytes)
}

test.run()
