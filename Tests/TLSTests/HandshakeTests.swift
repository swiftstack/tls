import Test
@testable import TLS

class HandshakeTests: TestCase {
    var bytes: [UInt8] { [0x0e, 0x00, 0x00, 0x00] }

    func testDecode() throws {
        let handshake = try Handshake(from: bytes)
        expect(handshake == .serverHelloDone)
    }

    func testEncode() throws {
        let result = try Handshake.serverHelloDone.encode()
        expect(result == bytes)
    }
}
