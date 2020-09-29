import Test
import Stream
@testable import TLS

class ExtensionSessionTicketTests: TestCase {
    func testDecodeEmpty() throws {
        let stream = InputByteStream([0x00, 0x23, 0x00, 0x00])
        let result = try Extension(from: stream)
        expect(result == .sessionTicket(.init(data: [])))
    }

    func testDecodeEmptyRandom() throws {
        let stream = InputByteStream(
            [0x00, 0x23, 0x00, 0x05, 0xFF, 0xA3, 0x7B, 0x04, 0x33])
        let result = try Extension(from: stream)
        expect(result == .sessionTicket(
            .init(data: [0xFF, 0xA3, 0x7B, 0x04, 0x33])))
    }

    func testEncodeEmpty() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x00, 0x23, 0x00, 0x00]
        let sessionTicket = Extension.sessionTicket(.init(data: []))
        try sessionTicket.encode(to: stream)
        expect(stream.bytes == expected)
    }

    func testEncodeEmptyRandom() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] =
            [0x00, 0x23, 0x00, 0x05, 0xFF, 0xA3, 0x7B, 0x04, 0x33]
        let sessionTicket = Extension.sessionTicket(
            .init(data: [0xFF, 0xA3, 0x7B, 0x04, 0x33]))
        try sessionTicket.encode(to: stream)
        expect(stream.bytes == expected)
    }
}
