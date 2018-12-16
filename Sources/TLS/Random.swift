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
        var bytes = [UInt8](repeating: 0, count: Random.bytesSize)
        for i in 0..<Random.bytesSize {
            bytes[i] = UInt8.random(in: 0...UInt8.max)
        }
        return bytes
    }
}

extension Random {
    init(from stream: StreamReader) throws {
        self.time = Int(try stream.read(UInt32.self))
        self.bytes = try stream.read(count: 28)
    }

    func encode(to stream: StreamWriter) throws {
        assert(bytes.count == 28)
        try stream.write(UInt32(time))
        try stream.write(bytes)
    }
}
