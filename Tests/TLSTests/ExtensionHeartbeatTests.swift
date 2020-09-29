import Test
import Stream
@testable import TLS

class ExtensionHeartbeatTests: TestCase {
    func testDecode() throws {
        let stream = InputByteStream([0x01])
        let result = try Extension.Heartbeat(from: stream)
        expect(result == .init(mode: .allowed))
    }

    func testDecodeExtension() throws {
        let stream = InputByteStream([0x00, 0x0f, 0x00, 0x01, 0x01])
        let result = try Extension(from: stream)
        expect(result == .heartbeat(.init(mode: .allowed)))
    }

    func testEncode() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x01]
        let heartbeat = Extension.Heartbeat(mode: .allowed)
        try heartbeat.encode(to: stream)
        expect(stream.bytes == expected)
    }

    func testEncodeExtension() throws {
        let stream = OutputByteStream()
        let expected: [UInt8] = [0x00, 0x0f, 0x00, 0x01, 0x01]
        let heartbeat = Extension.heartbeat(.init(mode: .allowed))
        try heartbeat.encode(to: stream)
        expect(stream.bytes == expected)
    }
}
