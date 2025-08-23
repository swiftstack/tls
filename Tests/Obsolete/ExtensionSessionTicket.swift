import Testing
@testable import TLS

private let emptyTicketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x00]

private let ticketData: [UInt8] = [0xFF, 0xA3, 0x7B, 0x04, 0x33]
private let ticketBytes: [UInt8] = [0x00, 0x23, 0x00, 0x05] + ticketData

@Test
func `decode empty session ticket extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: emptyTicketBytes)
    #expect(result == .obsolete(.sessionTicket(.init(data: []))))
}

@Test
func `decode session ticket extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: ticketBytes)
    #expect(result == .obsolete(.sessionTicket(.init(data: ticketData))))
}

@Test
func `encode empty session ticket extension`() async throws {
    let sessionTicket = Extension.Obsolete.sessionTicket(.init(data: []))
    let result = try await sessionTicket.encode()
    #expect(result == emptyTicketBytes)
}

@Test
func `encode session ticket extension`() async throws {
    let sessionTicket = Extension.Obsolete
        .sessionTicket(.init(data: ticketData))
    let result = try await sessionTicket.encode()
    #expect(result == ticketBytes)
}
