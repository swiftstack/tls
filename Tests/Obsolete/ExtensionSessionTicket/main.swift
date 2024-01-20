import Test
@testable import TLS

let emptyTicketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x00]

let ticketData: [UInt8] = [0xFF, 0xA3, 0x7B, 0x04, 0x33]
let ticketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x05] + ticketData

test("DecodeEmpty") {
    let result = try await ClientHello.Extension.decode(from: emptyTicketBytes)
    expect(result == .obsolete(.sessionTicket(.init(data: []))))
}

test("DecodeRandom") {
    let result = try await ClientHello.Extension.decode(from: ticketBytes)
    expect(result == .obsolete(.sessionTicket(.init(data: ticketData))))
}

test("EncodeEmpty") {
    let sessionTicket = Extension.Obsolete.sessionTicket(.init(data: []))
    let result = try await sessionTicket.encode()
    expect(result == emptyTicketBytes)
}

test("EncodeEmptyRandom") {
    let sessionTicket = Extension.Obsolete
        .sessionTicket(.init(data: ticketData))
    let result = try await sessionTicket.encode()
    expect(result == ticketBytes)
}

await run()
