import Test
@testable import TLS

let bytes: [UInt8] = [0x00]
let extensionBytes: [UInt8] = [0xff, 0x01, 0x00, 0x01] + bytes

test.case("Decode") {
    let result = try await Extension.RenegotiationInfo.decode(from: bytes)
    expect(result == .init(renegotiatedConnection: []))
}

test.case("DecodeExtension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .obsolete(.renegotiationInfo(.init())))
}

test.case("Encode") {
    let info = Extension.RenegotiationInfo(renegotiatedConnection: [])
    let result = try await info.encode()
    expect(result == bytes)
}

test.case("EncodeExtension") {
    let info = Extension.Obsolete.renegotiationInfo(.init())
    let result = try await info.encode()
    expect(result == extensionBytes)
}

test.run()
