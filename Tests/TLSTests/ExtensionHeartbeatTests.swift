import Test
@testable import TLS

class ExtensionHeartbeatTests: TestCase {
    var bytes: [UInt8] { [0x01] }
    var extensionBytes: [UInt8] { [0x00, 0x0f, 0x00, 0x01] + bytes }

    func testDecode() throws {
        let result = try Extension.Heartbeat(bytes)
        expect(result == .init(mode: .allowed))
    }

    func testDecodeExtension() throws {
        let result = try Extension(extensionBytes)
        expect(result == .heartbeat(.init(mode: .allowed)))
    }

    func testEncode() throws {
        let heartbeat = Extension.Heartbeat(mode: .allowed)
        let result = try heartbeat.encode()
        expect(result == bytes)
    }

    func testEncodeExtension() throws {
        let heartbeat = Extension.heartbeat(.init(mode: .allowed))
        let result = try heartbeat.encode()
        expect(result == extensionBytes)
    }
}
