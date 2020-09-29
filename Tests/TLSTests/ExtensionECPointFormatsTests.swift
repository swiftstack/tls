import Test
@testable import TLS

class ExtensionECPointFormatsTests: TestCase {
    typealias ECPointFormat = Extension.ECPointFormat

    var ecPointFormatBytes: [UInt8] {
        [0x03, 0x00, 0x01, 0x02]
    }

    var ecPointFormatExtensionBytes: [UInt8] {
        [0x00, 0x0b, 0x00, 0x04] + ecPointFormatBytes
    }

    func testDecode() throws {
        let result = try [ECPointFormat](ecPointFormatBytes)
        expect(result == [
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2])
    }

    func testDecodeExtension() throws {
        let result = try Extension(ecPointFormatExtensionBytes)
        expect(result == .ecPointFormats([
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2]))
    }

    func testEncode() throws {
        let formats: [ECPointFormat] = [
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2
        ]
        let result = try formats.encode()
        expect(result == ecPointFormatBytes)
    }

    func testEncodeExtension() throws {
        let formatsExtension = Extension.ecPointFormats([
            .uncompressed,
            .ansiX962_compressed_prime,
            .ansiX962_compressed_char2])
        let result = try formatsExtension.encode()
        expect(result == ecPointFormatExtensionBytes)
    }
}
