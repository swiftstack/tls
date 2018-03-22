import Test
import Stream
@testable import TLS

class RecordLayerTests: TestCase {
    func testRecordLayer() {
        scope {
            let stream = InputByteStream([0x18, 0x03, 0x01, 0x00, 0x00])
            let recordLayer = try RecordLayer(from: stream)
            assertEqual(
                recordLayer,
                .init(version: .tls10, content: .heartbeat))
        }
    }
}
