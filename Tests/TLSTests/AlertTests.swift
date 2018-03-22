import Test
import Stream
@testable import TLS

class AlertTests: TestCase {
    func testAlert() {
        scope {
            let stream = InputByteStream([0x01, 0x00])
            let alert = try Alert(from: stream)
            assertEqual(alert.level, .warning)
            assertEqual(alert.description, .closeNotify)
        }
    }
}
