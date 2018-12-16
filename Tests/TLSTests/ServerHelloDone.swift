import Test
import Stream
@testable import TLS

class ServerHelloDone: TestCase {
    let bytes: [UInt8] = [0x16, 0x03, 0x03, 0x00, 0x04, 0x0e, 0x00, 0x00, 0x00]

    func testDecode() {
        scope {
            let stream = InputByteStream(bytes)
            let record = try RecordLayer(from: stream)
            assertEqual(record.version, .tls12)
            assertEqual(record.content, .handshake(.serverHelloDone))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let record = RecordLayer(
                version: .tls12,
                content: .handshake(.serverHelloDone))
            try record.encode(to: stream)
            assertEqual(stream.bytes, bytes)
        }
    }
}
