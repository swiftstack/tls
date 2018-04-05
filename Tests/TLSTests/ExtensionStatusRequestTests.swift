import Test
import Stream
@testable import TLS

class ExtensionStatusRequestTests: TestCase {
    func testDecode() {
        scope {
            let stream = InputByteStream([0x01, 0x00, 0x00, 0x00, 0x00])
            let result = try Extension.StatusRequest(from: stream)
            assertEqual(result, .init(certificateStatus: .ocsp))
        }
    }

    func testDecodeExtension() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00])
            let result = try Extension(from: stream)
            assertEqual(result, .statusRequest(.init(certificateStatus: .ocsp)))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00]
            let statusRequest = Extension.StatusRequest(
                certificateStatus: .ocsp)
            try statusRequest.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncodeExtension() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00]
            let statusRequest = Extension.statusRequest(
                .init(certificateStatus: .ocsp))
            try statusRequest.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
