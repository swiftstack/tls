import Stream

public struct Finished: Equatable {
    let hmac: [UInt8]
}

extension Finished: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        .init(hmac: try await stream.readUntilEnd())
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(hmac)
    }
}
