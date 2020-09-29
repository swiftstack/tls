import Test
@testable import TLS

class ExtensionStatusRequestTests: TestCase {
    typealias StatusRequest = Extension.StatusRequest

    var bytes: [UInt8] { [0x01, 0x00, 0x00, 0x00, 0x00] }
    var extensionBytes: [UInt8] { [0x00, 0x05, 0x00, 0x05] + bytes }

    func testDecode() throws {
        let result = try StatusRequest(bytes)
        expect(result == .ocsp(.init()))
    }

    func testDecodeExtension() throws {
        let result = try Extension(extensionBytes)
        expect(result == .statusRequest(.ocsp(.init())))
    }

    func testEncode() throws {
        let statusRequest = StatusRequest.ocsp(.init())
        let result = try statusRequest.encode()
        expect(result == bytes)
    }

    func testEncodeExtension() throws {
        let statusRequest = Extension.statusRequest(.ocsp(.init()))
        let result = try statusRequest.encode()
        expect(result == extensionBytes)
    }
}
