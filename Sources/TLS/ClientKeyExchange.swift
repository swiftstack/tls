import Stream

public struct ClientKeyExchange: Equatable {
    public let pubkey: [UInt8]

    public init(pubkey: [UInt8]) {
        self.pubkey = pubkey
    }
}

extension ClientKeyExchange {
    static func decode(from stream: StreamReader) async throws -> Self {
        let length = Int(try await stream.read(UInt8.self))
        return .init(pubkey: try await stream.read(count: length))
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt8(pubkey.count))
        try await stream.write(pubkey)
    }
}
