import Test
import Stream
@testable import TLS

class AlertTests: TestCase {
    func testDecode() throws {
        let stream = InputByteStream([0x01, 0x00])
        let alert = try Alert(from: stream)
        expect(alert.level == .warning)
        expect(alert.description == .closeNotify)
    }

    func testEncode() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x01, 0x00]
        let alert = Alert(level: .warning, description: .closeNotify)
        try alert.encode(to: stream)
        expect(stream.bytes == expected)
    }
}
