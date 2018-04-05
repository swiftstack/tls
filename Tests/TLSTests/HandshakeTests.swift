import Test
import Stream
@testable import TLS

class HandshakeTests: TestCase {
    func testDecode() {
        scope {
            let stream = InputByteStream([0x0e, 0x00, 0x00, 0x00])
            let handshake = try Handshake(from: stream)
            assertEqual(handshake, .serverHelloDone)
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            try Handshake.serverHelloDone.encode(to: stream)
            assertEqual(stream.bytes, [0x0e, 0x00, 0x00, 0x00])
        }
    }
}
