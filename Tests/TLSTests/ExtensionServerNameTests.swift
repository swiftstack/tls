import Test
import Stream
@testable import TLS

class ExtensionServerNameTests: TestCase {
    typealias ServerName = Extension.ServerName

    func testDecodeName() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try ServerName(from: stream)
            assertEqual(result.type, .hostName)
            assertEqual(result.value, "ya.ru")
        }
    }

    func testDecode() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x08, 0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try [ServerName](from: stream)
            assertEqual(result, [.init(type: .hostName, value: "ya.ru")])
        }
    }

    func testDecodeExtension() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x00, 0x00, 0x0a, 0x00, 0x08, 0x00, 0x00,
                 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try Extension(from: stream)
            assertEqual(result, .serverName([
                .init(type: .hostName, value: "ya.ru")]))
        }
    }

    func testEncodeName() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75]
            let name = ServerName(type: .hostName, value: "ya.ru")
            try name.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncode() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x08, 0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75]
            let serverName = [ServerName]([
                .init(type: .hostName, value: "ya.ru")])
            try serverName.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }

    func testEncodeExtension() {
        scope {
            let stream = OutputByteStream()
            let expected: [UInt8] =
                [0x00, 0x00, 0x00, 0x0a, 0x00, 0x08, 0x00, 0x00,
                 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75]
            let serverNameExtension = Extension.serverName([
                .init(type: .hostName, value: "ya.ru")])
            try serverNameExtension.encode(to: stream)
            assertEqual(stream.bytes, expected)
        }
    }
}
