import Test
@testable import TLS

let bytes: [UInt8] = [0x0e, 0x00, 0x00, 0x00]

test.case("Decode") {
    let handshake = try await Handshake.decode(from: bytes)
    expect(handshake == .serverHelloDone)
}

test.case("Encode") {
    let result = try await Handshake.serverHelloDone.encode()
    expect(result == bytes)
}

test.run()
