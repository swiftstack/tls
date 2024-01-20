import Test
@testable import TLS

test("decode tls version") {
    expect(Version(rawValue: 0x0301) == .tls10)
    expect(Version(rawValue: 0x0302) == .tls11)
    expect(Version(rawValue: 0x0303) == .tls12)
    expect(Version(rawValue: 0x0304) == .tls13)
}

test("encode tls version") {
    expect(Version.tls10.rawValue == 0x0301)
    expect(Version.tls11.rawValue == 0x0302)
    expect(Version.tls12.rawValue == 0x0303)
    expect(Version.tls13.rawValue == 0x0304)
}

await run()
