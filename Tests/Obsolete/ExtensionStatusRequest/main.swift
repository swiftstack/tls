import Test
@testable import TLS

typealias StatusRequest = Extension.StatusRequest

let bytes: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00]
let extensionBytes: [UInt8] = [0x00, 0x05, 0x00, 0x05] + bytes

test.case("Decode") {
    let result = try await StatusRequest.decode(from: bytes)
    expect(result == .ocsp(.init()))
}

test.case("DecodeExtension") {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    expect(result == .obsolete(.statusRequest(.ocsp(.init()))))
}

test.case("Encode") {
    let statusRequest = StatusRequest.ocsp(.init())
    let result = try await statusRequest.encode()
    expect(result == bytes)
}

test.case("EncodeExtension") {
    let statusRequest = Extension.Obsolete.statusRequest(.ocsp(.init()))
    let result = try await statusRequest.encode()
    expect(result == extensionBytes)
}

test.run()
