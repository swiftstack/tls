import Test
@testable import TLS

typealias PostHandshakeAuth = Extension.PostHandshakeAuth

let value = PostHandshakeAuth()
let bytes: [UInt8] = [0x00, 0x31, 0x00, 0x00]

test("decode post_handshake_auth extension") {
    let result = try await ClientHello.Extension.decode(from: bytes)
    expect(result == .postHandshakeAuth(value))
}

test("encode post_handshake_auth extension") {
    let phaExtension = ClientHello.Extension.postHandshakeAuth(value)
    let result = try await phaExtension.encode()
    expect(result == bytes)
}

await run()
