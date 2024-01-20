import Test
@testable import TLS

typealias NextProtocolNegotiation = Extension.NextProtocolNegotiation

let npn: NextProtocolNegotiation = .none

let npnBytes: [UInt8] =
    []

let npnExtensionBytes: [UInt8] =
    [0x33, 0x74, 0x00, 0x00] + npnBytes

test("decode next_protocol_negotiation") {
    let result = try await NextProtocolNegotiation.decode(from: npnBytes)
    expect(result == npn)
}

test("decode next_protocol_negotiation extension") {
    let result = try await Extension.Obsolete.decode(from: npnExtensionBytes)
    expect(result == .nextProtocolNegotiation(npn))
}

test("encode next_protocol_negotiation") {
    let result = try await npn.encode()
    expect(result == npnBytes)
}

test("encode next_protocol_negotiation extension") {
    let npnExtension = Extension.Obsolete.nextProtocolNegotiation(npn)
    let result = try await npnExtension.encode()
    expect(result == npnExtensionBytes)
}

await run()
