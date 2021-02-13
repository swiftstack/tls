import Stream

extension Extension {
    public struct SessionTicket: Equatable {
        public let data: [UInt8]

        public init(data: [UInt8]) {
            self.data = data
        }
    }
}

extension Extension.SessionTicket {
    static func decode(from stream: StreamReader) async throws -> Self {
        return .init(data: try await stream.readUntilEnd())
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(data)
    }
}
