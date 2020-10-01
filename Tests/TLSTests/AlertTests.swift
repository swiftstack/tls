import Test
@testable import TLS

class AlertTests: TestCase {
    var bytes: [UInt8] { [0x01, 0x00] }

    func testDecode() throws {
        let alert = try Alert(from: bytes)
        expect(alert.level == .warning)
        expect(alert.description == .closeNotify)
    }

    func testEncode() throws {
        let alert = Alert(level: .warning, description: .closeNotify)
        let result = try alert.encode()
        expect(result == bytes)
    }
}
