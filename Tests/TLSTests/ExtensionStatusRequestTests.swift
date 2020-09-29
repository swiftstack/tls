import Test
import Stream
@testable import TLS

class ExtensionStatusRequestTests: TestCase {
    typealias StatusRequest = Extension.StatusRequest

    func testDecode() throws {
        let stream = InputByteStream([0x01, 0x00, 0x00, 0x00, 0x00])
        let result = try StatusRequest(from: stream)
        expect(result == .ocsp(.init()))
    }

    func testDecodeExtension() throws {
        let stream = InputByteStream(
            [0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00])
        let result = try Extension(from: stream)
        expect(result == .statusRequest(.ocsp(.init())))
    }

    func testEncode() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00]
        let statusRequest = StatusRequest.ocsp(.init())
        try statusRequest.encode(to: stream)
        expect(stream.bytes == expected)
    }

    func testEncodeExtension() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] =
            [0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00]
        let statusRequest = Extension.statusRequest(.ocsp(.init()))
        try statusRequest.encode(to: stream)
        expect(stream.bytes == expected)
    }
}
