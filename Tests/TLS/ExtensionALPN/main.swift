import Test
@testable import TLS

typealias ALPN = Extension.ALPN

let alpn: ALPN = [
    .http2, .http11
]

let bytes: [UInt8] = [
    // length
    0x00, 0x0c,
    // names
    0x02, 0x68, 0x32,
    0x08, 0x68, 0x74, 0x74, 0x70, 0x2f, 0x31, 0x2e, 0x31
]

let extensionBytes: [UInt8] =
    [0x00, 0x10, 0x00, 0x0e] + bytes

test("decode next protocol") {
    let result = try await ALPN.decode(from: bytes)
    expect(result == alpn)
}

test("decode next protocol extension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .alpn(alpn))
}

test("encode next protocol") {
    let result = try await alpn.encode()
    expect(result == bytes)
}

test("encode next protocol extension") {
    let alpnExtension = ClientHello.Extension.alpn(alpn)
    let result = try await alpnExtension.encode()
    expect(result == extensionBytes)
}

await run()
