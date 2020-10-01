import Test
@testable import TLS

class ServerHelloDone: TestCase {
    let bytes: [UInt8] = [0x16, 0x03, 0x03, 0x00, 0x04, 0x0e, 0x00, 0x00, 0x00]

    func testDecode() throws {
        let record = try RecordLayer(from: bytes)
        expect(record.version == .tls12)
        expect(record.content == .handshake(.serverHelloDone))
    }

    func testEncode() throws {
        let record = RecordLayer(
            version: .tls12,
            content: .handshake(.serverHelloDone))
        let result = try record.encode()
        expect(result == bytes)
    }
}
