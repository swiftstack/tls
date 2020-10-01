import Test
@testable import TLS

class ExtensionRenegotiationInfoTests: TestCase {
    var bytes: [UInt8] { [0x00] }
    var extensionBytes: [UInt8] { [0xff, 0x01, 0x00, 0x01] + bytes }

    func testDecode() throws {
        let result = try Extension.RenegotiationInfo(from: bytes)
        expect(result == .init(renegotiatedConnection: []))
    }

    func testDecodeExtension() throws {
        let result = try Extension(from: extensionBytes)
        expect(result == .renegotiationInfo(.init()))
    }

    func testEncode() throws {
        let info = Extension.RenegotiationInfo(renegotiatedConnection: [])
        let result = try info.encode()
        expect(result == bytes)
    }

    func testEncodeExtension() throws {
        let info = Extension.renegotiationInfo(.init())
        let result = try info.encode()
        expect(result == extensionBytes)
    }
}
