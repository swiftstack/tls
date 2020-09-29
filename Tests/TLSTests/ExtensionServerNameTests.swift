import Test
@testable import TLS

class ExtensionServerNameTests: TestCase {
    typealias ServerName = Extension.ServerName

    var bytes: [UInt8] { [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75] }
    var manyBytes: [UInt8] { [0x00, 0x08] + bytes }
    var extensionBytes: [UInt8] { [0x00, 0x00, 0x00, 0x0a] + manyBytes }

    func testDecodeOne() throws {
        let result = try ServerName(bytes)
        expect(result.type == .hostName)
        expect(result.value == "ya.ru")
    }

    func testDecodeMany() throws {
        let result = try [ServerName](manyBytes)
        expect(result == [.init(type: .hostName, value: "ya.ru")])
    }

    func testDecodeExtension() throws {
        let result = try Extension(extensionBytes)
        expect(result == .serverName([
            .init(type: .hostName, value: "ya.ru")]))
    }

    func testEncodeOne() throws {
        let name = ServerName(type: .hostName, value: "ya.ru")
        let result = try name.encode()
        expect(result == bytes)
    }

    func testEncodeMany() throws {
        let serverName = [ServerName]([
            .init(type: .hostName, value: "ya.ru")])
        let result = try serverName.encode()
        expect(result == manyBytes)
    }

    func testEncodeExtension() throws {
        let serverNameExtension = Extension.serverName([
            .init(type: .hostName, value: "ya.ru")])
        let result = try serverNameExtension.encode()
        expect(result == extensionBytes)
    }
}
