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
        var bytes = [UInt8](repeating: 0, count: Random.bytesSize)
        arc4random_buf(&bytes, bytes.count)
        self.bytes = bytes
    }
}

extension Random {
    init<T: StreamReader>(from stream: T) throws {
        self.time = Int(try stream.read(UInt32.self).byteSwapped)
        self.bytes = try stream.read(count: 28)
    }
}
