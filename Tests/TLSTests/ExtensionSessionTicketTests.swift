import Test
@testable import TLS

class ExtensionSessionTicketTests: TestCase {
    var emptyTicketBytes: [UInt8] { [0x00, 0x23, 0x00, 0x00] }

    var ticketData: [UInt8] { [0xFF, 0xA3, 0x7B, 0x04, 0x33] }
    var ticketBytes: [UInt8] { [0x00, 0x23, 0x00, 0x05] + ticketData }

    func testDecodeEmpty() throws {
        let result = try Extension(from: emptyTicketBytes)
        expect(result == .sessionTicket(.init(data: [])))
    }

    func testDecodeRandom() throws {
        let result = try Extension(from: ticketBytes)
        expect(result == .sessionTicket(.init(data: ticketData)))
    }

    func testEncodeEmpty() throws {
        let sessionTicket = Extension.sessionTicket(.init(data: []))
        let result = try sessionTicket.encode()
        expect(result == emptyTicketBytes)
    }

    func testEncodeEmptyRandom() throws {
        let sessionTicket = Extension.sessionTicket(.init(data: ticketData))
        let result = try sessionTicket.encode()
        expect(result == ticketBytes)
    }
}
