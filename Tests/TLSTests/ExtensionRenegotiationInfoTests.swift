import Test
import Stream
@testable import TLS

class ExtensionRenegotiationInfoTests: TestCase {
    func testDecode() throws {
        let stream = InputByteStream([0x00])
        let result = try Extension.RenegotiationInfo(from: stream)
        expect(result == .init(renegotiatedConnection: []))
    }

    func testDecodeExtension() throws {
        let stream = InputByteStream([0xff, 0x01, 0x00, 0x01, 0x00])
        let result = try Extension(from: stream)
        expect(result == .renegotiationInfo(.init()))
    }

    func testEncode() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x00]
        let info = Extension.RenegotiationInfo(renegotiatedConnection: [])
        try info.encode(to: stream)
        expect(stream.bytes == expected)
    }

    func testEncodeExtension() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0xff, 0x01, 0x00, 0x01, 0x00]
        let info = Extension.renegotiationInfo(.init())
        try info.encode(to: stream)
        expect(stream.bytes == expected)
    }
}
