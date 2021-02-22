import Test
@testable import TLS

let bytes: [UInt8] = [0x01]
let extensionBytes: [UInt8] = [0x00, 0x0f, 0x00, 0x01] + bytes

test.case("Decode") {
    let result = try await Extension.Heartbeat.decode(from: bytes)
    expect(result == .init(mode: .allowed))
}

test.case("DecodeExtension") {
    let result = try await Extension.Encrypted.decode(from: extensionBytes)
    expect(result == .heartbeat(.init(mode: .allowed)))
}

test.case("Encode") {
    let heartbeat = Extension.Heartbeat(mode: .allowed)
    let result = try await heartbeat.encode()
    expect(result == bytes)
}

test.case("EncodeExtension") {
    let heartbeat = Extension.Encrypted.heartbeat(.init(mode: .allowed))
    let result = try await heartbeat.encode()
    expect(result == extensionBytes)
}

test.run()
