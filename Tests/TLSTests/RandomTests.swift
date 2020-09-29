import Test
@testable import TLS

class RandomTests: TestCase {
    func testRandom() {
        let random = Random()
        expect(random.time > 0)
        expect(Random().bytes != Random().bytes)
    }

    func testRandomBytes() {
        let random = Random()
        guard !random.bytes.isEmpty else {
            fail("invalid random bytes")
            return
        }
        var allowedRepeatingBytesCount = 1
        for i in random.bytes.indices.dropLast() {
            if random.bytes[i] == random.bytes[i + 1] {
                allowedRepeatingBytesCount -= 1
            }
            guard allowedRepeatingBytesCount > 0 else {
                fail("it's very likely that random is broken")
                return
            }
        }
    }
}
