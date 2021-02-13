import Test
@testable import TLS

let emptyTicketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x00]

let ticketData: [UInt8] = [0xFF, 0xA3, 0x7B, 0x04, 0x33]
let ticketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x05] + ticketData

test.case("DecodeEmpty") {
    let result = try await Extension.decode(from: emptyTicketBytes)
    expect(result == .sessionTicket(.init(data: [])))
}

test.case("DecodeRandom") {
    let result = try await Extension.decode(from: ticketBytes)
    expect(result == .sessionTicket(.init(data: ticketData)))
}

test.case("EncodeEmpty") {
    let sessionTicket = Extension.sessionTicket(.init(data: []))
    let result = try await sessionTicket.encode()
    expect(result == emptyTicketBytes)
}

test.case("EncodeEmptyRandom") {
    let sessionTicket = Extension.sessionTicket(.init(data: ticketData))
    let result = try await sessionTicket.encode()
    expect(result == ticketBytes)
}

test.run()
