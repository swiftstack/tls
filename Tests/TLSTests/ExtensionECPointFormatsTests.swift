import Test
@testable import TLS

class ExtensionECPointFormatsTests: TestCase {
    typealias ECPointFormats = Extension.ECPointFormats

    var ecPointFormats: ECPointFormats {
        return [
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2
        ]
    }

    var ecPointFormatBytes: [UInt8] {
        [0x03, 0x00, 0x01, 0x02]
    }

    var ecPointFormatExtensionBytes: [UInt8] {
        [0x00, 0x0b, 0x00, 0x04] + ecPointFormatBytes
    }

    func testDecode() throws {
        let result = try ECPointFormats(ecPointFormatBytes)
        expect(result == ecPointFormats)
    }

    func testDecodeExtension() throws {
        let result = try Extension(ecPointFormatExtensionBytes)
        expect(result == .ecPointFormats(ecPointFormats))
    }

    func testEncode() throws {
        let result = try ecPointFormats.encode()
        expect(result == ecPointFormatBytes)
    }

    func testEncodeExtension() throws {
        let formatsExtension = Extension.ecPointFormats(ecPointFormats)
        let result = try formatsExtension.encode()
        expect(result == ecPointFormatExtensionBytes)
    }
}
