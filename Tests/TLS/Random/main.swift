import Test
@testable import TLS

test.case("random") {
    let random = Random()
    expect(random.time > 0)
    expect(random.bytes.count == 28)
    expect(Random().bytes != Random().bytes)
}

test.case("silly random check") {
    let random = Random()
    guard !random.bytes.isEmpty else {
        return
    }
    var tolerance = 3
    for i in random.bytes.indices.dropLast() {
        if random.bytes[i] == random.bytes[i + 1] {
            tolerance -= 1
        }
        guard tolerance > 0 else {
            fail("random ain't random")
            return
        }
    }
}

test.run()
