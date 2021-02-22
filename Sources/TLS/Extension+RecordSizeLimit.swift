import Stream

extension Extension {
    public struct RecordSizeLimit: Equatable {
        public let value: Int

        public init(_ value: Int) {
            self.value = value
        }
    }
}

extension Extension.RecordSizeLimit {
    static func decode(from stream: StreamReader) async throws -> Self {
        let value = try await stream.read(UInt16.self)
        return .init(Int(value))
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt16(truncatingIfNeeded: value))
    }
}
