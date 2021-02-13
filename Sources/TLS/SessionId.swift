import Stream

public struct SessionId: Equatable {
    public let data: [UInt8]

    public init(data: [UInt8]) {
        self.data = data
    }
}

extension SessionId {
    static func decode(from stream: StreamReader) async throws -> Self {
        let length = Int(try await stream.read(UInt8.self))

        guard length > 0 else {
            return .init(data: [])
        }

        return .init(data: try await stream.read(count: length))
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt8(data.count))
        try await stream.write(data)
    }
}
