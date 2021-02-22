import Stream
import Platform

public struct Random: Equatable {
    public let time: Int
    public let bytes: [UInt8]

    fileprivate static let bytesSize = 28
}

extension Random {
    public init() {
        self.time = Platform.time(nil)
        self.bytes = Random.generate()
    }

    static func generate() -> [UInt8] {
        return (0..<bytesSize).map { _ in .random(in: 0...UInt8.max) }
    }
}

extension Random {
    static func decode(from stream: StreamReader) async throws -> Self {
        let time = Int(try await stream.read(UInt32.self))
        let bytes = try await stream.read(count: 28)
        return .init(time: time, bytes: bytes)
    }

    func encode(to stream: StreamWriter) async throws {
        assert(bytes.count == 28)
        try await stream.write(UInt32(time))
        try await stream.write(bytes)
    }
}
