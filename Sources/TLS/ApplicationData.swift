import Stream

public struct ApplicationData: Equatable {
    let bytes: [UInt8]
}

extension ApplicationData: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        .init(bytes: try await stream.readUntilEnd())
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(bytes)
    }
}

extension ApplicationData: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        self.init(bytes: [UInt8](elements))
    }
}
