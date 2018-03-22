import Test
import Stream
@testable import TLS

class ExtensionStatusRequestTests: TestCase {
    func testExtensionStatusRequest() {
        scope {
            let stream = InputByteStream([0x01, 0x00, 0x00, 0x00, 0x00])
            let result = try Extension.StatusRequest(from: stream)
            assertEqual(result, .init(certificateStatus: .ocsp))
        }
    }

    func testExtensionStatusRequestType() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x05, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00])
            let result = try Extension(from: stream)
            assertEqual(result, .statusRequest(.init(certificateStatus: .ocsp)))
        }
    }
}
