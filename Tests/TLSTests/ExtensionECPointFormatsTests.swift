import Test
import Stream
@testable import TLS

class ExtensionECPointFormatsTests: TestCase {
    func testDecode() {
        scope {
            let stream = InputByteStream([0x03, 0x00, 0x01, 0x02])
            let result = try Extension.ECPointFormats(from: stream)
            assertEqual(result, .init(values: [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2]))
        }
    }

    func testDecodeExtension() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02])
            let result = try Extension(from: stream)
            assertEqual(result, .ecPointFormats(.init(values: [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2])))
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] = [0x03, 0x00, 0x01, 0x02]
            let formats = Extension.ECPointFormats(values: [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2])
            try formats.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncodeExtension() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x0b, 0x00, 0x04, 0x03, 0x00, 0x01, 0x02]
            let formatsExtension = Extension.ecPointFormats(.init(values: [
                .uncompressed,
                .ansiX962_compressed_prime,
                .ansiX962_compressed_char2]))
            try formatsExtension.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
