import Test
import Stream
@testable import TLS

class RecordLayerTests: TestCase {
    func testDecode() {
        scope {
            let stream = InputByteStream([0x18, 0x03, 0x01, 0x00, 0x00])
            let recordLayer = try RecordLayer(from: stream)
            assertEqual(
                recordLayer,
                .init(version: .tls10, content: .heartbeat))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x18, 0x03, 0x01, 0x00, 0x00]
            let recordLayer = RecordLayer(version: .tls10, content: .heartbeat)
            try recordLayer.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
