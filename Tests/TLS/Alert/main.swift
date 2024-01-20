import Test
@testable import TLS

let bytes: [UInt8] = [0x01, 0x00]

test("Decode") {
    let alert = try await Alert.decode(from: bytes)
    expect(alert.level == .warning)
    expect(alert.description == .closeNotify)
}

test("Encode") {
    let alert = Alert(level: .warning, description: .closeNotify)
    let result = try await alert.encode()
    expect(result == bytes)
}

await run()
