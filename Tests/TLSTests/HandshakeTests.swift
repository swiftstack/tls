import Test
import Stream
@testable import TLS

class HandshakeTests: TestCase {
    func testDecode() throws {
        let stream = InputByteStream([0x0e, 0x00, 0x00, 0x00])
        let handshake = try Handshake(from: stream)
        expect(handshake == .serverHelloDone)
    }

    func testEncode() throws {
        let stream = OutputByteStream()
        try Handshake.serverHelloDone.encode(to: stream)
        expect(stream.bytes == [0x0e, 0x00, 0x00, 0x00])
    }
}
