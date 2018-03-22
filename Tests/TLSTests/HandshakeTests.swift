import Test
import Stream
@testable import TLS

class HandshakeTests: TestCase {
    func testHandshake() {
        scope {
            let stream = InputByteStream([0x0e, 0x00, 0x00, 0x00])
            let handshake = try Handshake(from: stream)
            assertEqual(handshake, .serverHelloDone)
        }
    }
}
