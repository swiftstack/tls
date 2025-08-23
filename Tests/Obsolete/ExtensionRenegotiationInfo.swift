import Testing
@testable import TLS

private let bytes: [UInt8] = [0x00]
private let extensionBytes: [UInt8] = [0xff, 0x01, 0x00, 0x01] + bytes

@Test
func `decode renegotiation info`() async throws {
    let result = try await Extension.RenegotiationInfo.decode(from: bytes)
    #expect(result == .init(renegotiatedConnection: []))
}

@Test
func `decode renegotiation info extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    #expect(result == .obsolete(.renegotiationInfo(.init())))
}

@Test
func `encode renegotiation info`() async throws {
    let info = Extension.RenegotiationInfo(renegotiatedConnection: [])
    let result = try await info.encode()
    #expect(result == bytes)
}

@Test
func `encode renegotiation info extension`() async throws {
    let info = Extension.Obsolete.renegotiationInfo(.init())
    let result = try await info.encode()
    #expect(result == extensionBytes)
}
