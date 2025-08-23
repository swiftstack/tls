import Testing
@testable import TLS

private typealias StatusRequest = Extension.StatusRequest

private let bytes: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00]
private let extensionBytes: [UInt8] = [0x00, 0x05, 0x00, 0x05] + bytes

@Test
func `decode status request (OCSP)`() async throws {
    let result = try await StatusRequest.decode(from: bytes)
    #expect(result == .ocsp(.init()))
}

@Test
func `decode status request (OCSP) extension`() async throws {
    let result = try await ClientHello.Extension.decode(from: extensionBytes)
    #expect(result == .obsolete(.statusRequest(.ocsp(.init()))))
}

@Test
func `encode status request (OCSP)`() async throws {
    let statusRequest = StatusRequest.ocsp(.init())
    let result = try await statusRequest.encode()
    #expect(result == bytes)
}

@Test
func `encode status request (OCSP) extension`() async throws {
    let statusRequest = Extension.Obsolete.statusRequest(.ocsp(.init()))
    let result = try await statusRequest.encode()
    #expect(result == extensionBytes)
}
