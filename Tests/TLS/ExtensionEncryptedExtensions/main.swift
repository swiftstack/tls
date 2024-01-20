import Test
@testable import TLS

let bytes: [UInt8] = [0x08, 0x00, 0x00, 0x02, 0x00, 0x00]
let encryptedExtensions: Handshake = .encryptedExtensions(.init([]))

test("decode encrypted extensions") {
    let result = try await Handshake.decode(from: bytes)
    expect(result == encryptedExtensions)
}

test("encode encrypted extensions") {
    let result = try await encryptedExtensions.encode()
    expect(result == bytes)
}

await run()
