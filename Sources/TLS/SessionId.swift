import Stream

public struct SessionId: Equatable {
    public let data: [UInt8]

    public init(data: [UInt8]) {
        self.data = data
    }
}

extension SessionId {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt8.self))

        guard length > 0 else {
            self.data = []
            return
        }

        self.data = try stream.read(count: length)
    }
}
