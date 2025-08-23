import Testing
@testable import TLS

private typealias ServerName = Extension.ServerName
private typealias ServerNames = Extension.ServerNames

private let bytes: [UInt8] = [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75]
private let manyBytes: [UInt8] = [0x00, 0x08] + bytes
private let extensionBytes: [UInt8] = [0x00, 0x00, 0x00, 0x0a] + manyBytes

@Test
func `decode server name one`() async throws {
    let result = try await ServerName.decode(from: bytes)
    #expect(result.type == .hostName)
    #expect(result.value == "ya.ru")
}

@Test
func `decode server name many`() async throws {
    let result = try await ServerNames.decode(from: manyBytes)
    #expect(result == [.init(type: .hostName, value: "ya.ru")])
}

@Test
func `decode server name extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    #expect(result == .serverName([
        .init(type: .hostName, value: "ya.ru")]))
}

@Test
func `encode server name one`() async throws {
    let name = ServerName(type: .hostName, value: "ya.ru")
    let result = try await name.encode()
    #expect(result == bytes)
}

@Test
func `encode server name many`() async throws {
    let serverName = ServerNames([
        .init(type: .hostName, value: "ya.ru")])
    let result = try await serverName.encode()
    #expect(result == manyBytes)
}

@Test
func `encode server name extension`() async throws {
    let serverNameExtension = ClientHello.Extension.serverName([
        .init(type: .hostName, value: "ya.ru")])
    let result = try await serverNameExtension.encode()
    #expect(result == extensionBytes)
}
