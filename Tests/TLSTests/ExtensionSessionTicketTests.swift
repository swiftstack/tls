import Test
import Stream
@testable import TLS

class ExtensionSessionTicketTests: TestCase {
    func testDecodeEmpty() {
        scope {
            let stream = InputByteStream([0x00, 0x23, 0x00, 0x00])
            let result = try Extension(from: stream)
            assertEqual(result, .sessionTicket(.init(data: [])))
        }
    }

    func testDecodeEmptyRandom() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x23, 0x00, 0x05, 0xFF, 0xA3, 0x7B, 0x04, 0x33])
            let result = try Extension(from: stream)
            assertEqual(result, .sessionTicket(
                .init(data: [0xFF, 0xA3, 0x7B, 0x04, 0x33])))
        }
    }

    func testEncodeEmpty() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x00, 0x23, 0x00, 0x00]
            let sessionTicket = Extension.sessionTicket(.init(data: []))
            try sessionTicket.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncodeEmptyRandom() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x23, 0x00, 0x05, 0xFF, 0xA3, 0x7B, 0x04, 0x33]
            let sessionTicket = Extension.sessionTicket(
                .init(data: [0xFF, 0xA3, 0x7B, 0x04, 0x33]))
            try sessionTicket.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
