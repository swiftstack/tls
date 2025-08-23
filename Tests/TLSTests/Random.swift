import Testing
@testable import TLS

@Test
func `random`() async throws {
    let random = Random()
    #expect(random.time > 0)
    #expect(random.bytes.count == 28)
    #expect(Random().bytes != Random().bytes)
}

@Test
func `silly random check`() async throws {
    let random = Random()
    guard !random.bytes.isEmpty else {
        return
    }
    var tolerance = 3
    for i in random.bytes.indices.dropLast() {
        if random.bytes[i] == random.bytes[i + 1] {
            tolerance -= 1
        }
        try #require(tolerance > 0, "random ain't random")
    }
}
