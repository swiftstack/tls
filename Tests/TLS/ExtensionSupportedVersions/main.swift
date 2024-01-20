import Test
@testable import TLS

typealias SupportedVersions = Extension.SupportedVersions

let versions: SupportedVersions = [
    .tls13
]

let versionsBytes: [UInt8] = [0x02, 0x03, 0x04]

let versionsExtensionBytes: [UInt8] =
    [0x00, 0x2b, 0x00, 0x03] + versionsBytes

test("Decode") {
    let result = try await SupportedVersions.decode(from: versionsBytes)
    expect(result == versions)
}

test("DecodeExtension") {
    let result = try await ClientHello.Extension.decode(from: versionsExtensionBytes)
    expect(result == .supportedVersions(versions))
}

test("Encode") {
    let result = try await versions.encode()
    expect(result == versionsBytes)
}

test("EncodeExtension") {
    let supportedVersionsExtension = ClientHello.Extension.supportedVersions(versions)
    let result = try await supportedVersionsExtension.encode()
    expect(result == versionsExtensionBytes)
}

await run()
