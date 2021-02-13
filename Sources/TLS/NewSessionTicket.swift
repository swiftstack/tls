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
    static func decode(from stream: StreamReader) async throws -> Self {
        let lifetime = Int(try await stream.read(UInt32.self))
        let length = Int(try await stream.read(UInt16.self))
        let data = try await stream.read(count: length)
        return .init(lifetime: lifetime, data: data)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt32(lifetime))
        try await stream.write(UInt16(data.count))
        try await stream.write(data)
    }
}
