import Test
@testable import TLS

class ChangeCipherSpecTests: TestCase {
    let bytes: [UInt8] = [0x14, 0x03, 0x03, 0x00, 0x01, 0x01]

    func testDecode() throws {
        let record = try RecordLayer(from: bytes)
        expect(record.version == .tls12)
        expect(record.content == .changeChiperSpec(.default))
    }

    func testEncode() throws {
        let record = RecordLayer(
            version: .tls12,
            content: .changeChiperSpec(.default))
        let result = try record.encode()
        expect(result == bytes)
    }
}
