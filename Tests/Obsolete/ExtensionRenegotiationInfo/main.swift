import Test
@testable import TLS

let bytes: [UInt8] = [0x00]
let extensionBytes: [UInt8] = [0xff, 0x01, 0x00, 0x01] + bytes

test("Decode") {
    let result = try await Extension.RenegotiationInfo.decode(from: bytes)
    expect(result == .init(renegotiatedConnection: []))
}

test("DecodeExtension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .obsolete(.renegotiationInfo(.init())))
}

test("Encode") {
    let info = Extension.RenegotiationInfo(renegotiatedConnection: [])
    let result = try await info.encode()
    expect(result == bytes)
}

test("EncodeExtension") {
    let info = Extension.Obsolete.renegotiationInfo(.init())
    let result = try await info.encode()
    expect(result == extensionBytes)
}

await run()
