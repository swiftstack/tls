import Stream

public struct NewSessionTicket: Equatable {
    public let lifetime: Int
    public let data: [UInt8]

    public init(lifetime: Int, data: [UInt8]) {
        self.lifetime = lifetime
        self.data = data
    }
}

extension NewSessionTicket {
    init(from stream: StreamReader) throws {
        self.lifetime = Int(try stream.read(UInt32.self))
        let length = Int(try stream.read(UInt16.self))
        self.data = try stream.read(count: length)
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(UInt32(lifetime))
        try stream.write(UInt16(data.count))
        try stream.write(data)
    }
}
