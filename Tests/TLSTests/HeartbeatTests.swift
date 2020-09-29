import Test
@testable import TLS

class HeartbeatTests: TestCase {
    var bytes: [UInt8] { [0x18, 0x03, 0x01, 0x00, 0x00] }

    func testDecodeHeartbeat() throws {
        let recordLayer = try RecordLayer(bytes)
        expect(recordLayer == .init(version: .tls10, content: .heartbeat))
    }

    func testEncodeHeartbeat() throws {
        let recordLayer = RecordLayer(version: .tls10, content: .heartbeat)
        let result = try recordLayer.encode()
        expect(result == bytes)
    }
}
