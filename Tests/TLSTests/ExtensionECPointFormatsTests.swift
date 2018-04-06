import Test
import Stream
@testable import TLS

class ExtensionECPointFormatsTests: TestCase {
    typealias ECPointFormat = Extension.ECPointFormat

    func testDecode() {
        scope {
            let stream = InputByteStream([0x03, 0x00, 0x01, 0x02])
            let result = try [ECPointFormat](from: stream)
            assertEqual(result, [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2])
        }
    }

    func testDecodeExtension() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02])
            let result = try Extension(from: stream)
            assertEqual(result, .ecPointFormats([
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2]))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x03, 0x00, 0x01, 0x02]
            let formats: [ECPointFormat] = [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2
            ]
            try formats.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncodeExtension() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02]
            let formatsExtension = Extension.ecPointFormats([
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2])
            try formatsExtension.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
