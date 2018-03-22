import Test
import Stream
@testable import TLS

class ExtensionServerNameTests: TestCase {
    func testExtensionServerNameName() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try Extension.ServerName.Name(from: stream)
            assertEqual(result.type, .hostName)
            assertEqual(result.value, "ya.ru")
        }
    }

    func testExtensionServerName() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x08, 0x00, 0x00, 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try Extension.ServerName(from: stream)
            assertEqual(result, .init(values: [
                .init(type: .hostName, value: "ya.ru")]))
        }
    }

    func testExtensionServerNameType() {
        scope {
            let stream = InputByteStream(
                [0x00, 0x00, 0x00, 0x0a, 0x00, 0x08, 0x00, 0x00,
                 0x05, 0x79, 0x61, 0x2e, 0x72, 0x75])
            let result = try Extension(from: stream)
            assertEqual(result, .serverName(.init(values: [
                .init(type: .hostName, value: "ya.ru")])))
        }
    }
}
