import Test
@testable import TLS

typealias ECPointFormats = Extension.ECPointFormats

let ecPointFormats: ECPointFormats = [
    .uncompressed,
    .ansiX962_compressed_prime,
    .ansiX962_compressed_char2
]

let ecPointFormatBytes: [UInt8] =
    [0x03, 0x00, 0x01, 0x02]

let ecPointFormatExtensionBytes: [UInt8] =
    [0x00, 0x0b, 0x00, 0x04] + ecPointFormatBytes

test.case("Decode") {
    let result = try await ECPointFormats.decode(from: ecPointFormatBytes)
    expect(result == ecPointFormats)
}

test.case("DecodeExtension") {
    let result = try await Extension.decode(from: ecPointFormatExtensionBytes)
    expect(result == .ecPointFormats(ecPointFormats))
}

test.case("Encode") {
    let result = try await ecPointFormats.encode()
    expect(result == ecPointFormatBytes)
}

test.case("EncodeExtension") {
    let formatsExtension = Extension.ecPointFormats(ecPointFormats)
    let result = try await formatsExtension.encode()
    expect(result == ecPointFormatExtensionBytes)
}

test.run()
