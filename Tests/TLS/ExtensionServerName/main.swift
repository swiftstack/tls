import Test
@testable import TLS

typealias ServerName = Extension.ServerName
typealias ServerNames = Extension.ServerNames

let bytes: [UInt8] = [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75]
let manyBytes: [UInt8] = [0x00, 0x08] + bytes
let extensionBytes: [UInt8] = [0x00, 0x00, 0x00, 0x0a] + manyBytes

test.case("DecodeOne") {
    let result = try await ServerName.decode(from: bytes)
    expect(result.type == .hostName)
    expect(result.value == "ya.ru")
}

test.case("DecodeMany") {
    let result = try await ServerNames.decode(from: manyBytes)
    expect(result == [.init(type: .hostName, value: "ya.ru")])
}

test.case("DecodeExtension") {
    let result = try await Extension.decode(from: extensionBytes)
    expect(result == .serverName([
        .init(type: .hostName, value: "ya.ru")]))
}

test.case("EncodeOne") {
    let name = ServerName(type: .hostName, value: "ya.ru")
    let result = try await name.encode()
    expect(result == bytes)
}

test.case("EncodeMany") {
    let serverName = ServerNames([
        .init(type: .hostName, value: "ya.ru")])
    let result = try await serverName.encode()
    expect(result == manyBytes)
}

test.case("EncodeExtension") {
    let serverNameExtension = Extension.serverName([
        .init(type: .hostName, value: "ya.ru")])
    let result = try await serverNameExtension.encode()
    expect(result == extensionBytes)
}

test.run()
