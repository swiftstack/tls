import Testing
@testable import TLS

private typealias ECPointFormats = Extension.ECPointFormats

private let ecPointFormats: ECPointFormats = [
    .uncompressed,
    .ansiX962_compressed_prime,
    .ansiX962_compressed_char2
]

private let ecPointFormatBytes: [UInt8] =
    [0x03, 0x00, 0x01, 0x02]

private let ecPointFormatExtensionBytes: [UInt8] =
    [0x00, 0x0b, 0x00, 0x04] + ecPointFormatBytes

@Test
func `decode ec point formats`() async throws {
    let result = try await ECPointFormats
        .decode(from: ecPointFormatBytes)
    #expect(result == ecPointFormats)
}

@Test
func `decode ec point formats extension`() async throws {
    let result = try await Extension.Obsolete
        .decode(from: ecPointFormatExtensionBytes)
    #expect(result == .ecPointFormats(ecPointFormats))
}

@Test
func `encode ec point formats`() async throws {
    let result = try await ecPointFormats.encode()
    #expect(result == ecPointFormatBytes)
}

@Test
func `encode ec point formats extension`() async throws {
    let formatsExtension = Extension.Obsolete
        .ecPointFormats(ecPointFormats)
    let result = try await formatsExtension.encode()
    #expect(result == ecPointFormatExtensionBytes)
}
