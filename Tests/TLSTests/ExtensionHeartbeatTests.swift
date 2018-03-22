import Test
import Stream
@testable import TLS

class ExtensionHeartbeatTests: TestCase {
    func testExtensionHeartbeat() {
        scope {
            let stream = InputByteStream([0x01])
            let result = try Extension.Heartbeat(from: stream)
            assertEqual(result, .init(mode: .allowed))
        }
    }

    func testExtensionHeartbeatType() {
        scope {
            let stream = InputByteStream([0x00, 0x0f, 0x00, 0x01, 0x01])
            let result = try Extension(from: stream)
            assertEqual(result, .heartbeat(.init(mode: .allowed)))
        }
    }
}
