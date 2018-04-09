import Stream

public struct SessionId: Equatable {
    public let data: [UInt8]

    public init(data: [UInt8]) {
        self.data = data
    }
}

extension SessionId {
    init(from stream: StreamReader) throws {
        let length = Int(try stream.read(UInt8.self))

        guard length > 0 else {
            self.data = []
            return
        }

        self.data = try stream.read(count: length)
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(UInt8(data.count))
        try stream.write(data)
    }
}
