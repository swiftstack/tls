import Testing
@testable import TLS

private typealias NextProtocolNegotiation = Extension.NextProtocolNegotiation

private let npn: NextProtocolNegotiation = .none

private let npnBytes: [UInt8] = []

private let npnExtensionBytes: [UInt8] = [0x33, 0x74, 0x00, 0x00] + npnBytes

@Test
func `decode next_protocol_negotiation`() async throws {
    let result = try await NextProtocolNegotiation.decode(from: npnBytes)
    #expect(result == npn)
}

@Test
func `decode next_protocol_negotiation extension`() async throws {
    let result = try await Extension.Obsolete.decode(from: npnExtensionBytes)
    #expect(result == .nextProtocolNegotiation(npn))
}

@Test
func `encode next_protocol_negotiation`() async throws {
    let result = try await npn.encode()
    #expect(result == npnBytes)
}

@Test
func `encode next_protocol_negotiation extension`() async throws {
    let npnExtension = Extension.Obsolete.nextProtocolNegotiation(npn)
    let result = try await npnExtension.encode()
    #expect(result == npnExtensionBytes)
}
