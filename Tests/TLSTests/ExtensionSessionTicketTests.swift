import Test
import Stream
@testable import TLS

class ExtensionSessionTicketTests: TestCase {
    func testExtensionSessionTicketEmpty() {
        scope {
            let stream = InputByteStream([0x00, 0x23, 0x00, 0x00])
            let result = try Extension(from: stream)
            assertEqual(result, .sessionTicket(.init(data: [])))
        }
    }

    func testExtensionSessionTicketEmptyRandom() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x23, 0x00, 0x05, 0xFF, 0xA3, 0x7B, 0x04, 0x33])
            let result = try Extension(from: stream)
            assertEqual(result, .sessionTicket(
                .init(data: [0xFF, 0xA3, 0x7B, 0x04, 0x33])))
        }
    }
}
