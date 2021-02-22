import Stream

extension Extension {
    // TODO: Implement
    public struct NextProtocolNegotiation: Equatable {
        public let data: [UInt8]

        public static let none: NextProtocolNegotiation = .init(data: [])

        public init(data: [UInt8]) {
            self.data = data
        }
    }
}

extension Extension.NextProtocolNegotiation: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        return .init(data: try await stream.readUntilEnd())
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(data)
    }
}
