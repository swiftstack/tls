import Test
import Stream
@testable import TLS

class ExtensionRenegotiationInfoTests: TestCase {
    typealias RenegotiationInfo = Extension.RenegotiationInfo

    func testExtensionRenegotiationInfo() {
        scope {
            let stream = InputByteStream([0x00])
            let result = try Extension.RenegotiationInfo(from: stream)
            assertEqual(result, RenegotiationInfo(values: []))
        }
    }

    func testExtensionRenegotiationInfoType() {
        scope {
            let stream = InputByteStream([0xff, 0x01, 0x00, 0x01, 0x00])
            let result = try Extension(from: stream)
            assertEqual(result, .renegotiationInfo(.init(values: [])))
        }
    }
}
