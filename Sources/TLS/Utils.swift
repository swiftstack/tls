import Stream

extension RawRepresentable where RawValue == UInt8 {
    @inline(__always)
    static func decode(from stream: StreamReader) async throws -> Self? {
        let rawType = try await stream.read(UInt8.self)
        return .init(rawValue: rawType)
    }

    @inline(__always)
    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}

// MARK: - Tests support

// MARK: Add simplified init(_ bytes: [UInt8]) throws

extension ClientHello: StreamCodable {}
extension ServerHello: StreamCodable {}
extension Handshake: StreamCodable {}
extension Alert: StreamCodable {}
extension Record: StreamCodable {}
extension ClientKeyExchange: StreamCodable {}
extension Extension.Heartbeat: StreamCodable {}
extension Extension.RenegotiationInfo: StreamCodable {}
extension Extension.StatusRequest: StreamCodable {}
extension ServerKeyExchange: StreamCodable {}

extension StreamDecodable {
    static func decode(from bytes: [UInt8]) async throws -> Self {
        let stream = InputByteStream(bytes)
        return try await Self.decode(from: stream)
    }
}

extension StreamEncodable {
    func encode() async throws -> [UInt8] {
        let stream = OutputByteStream()
        try await self.encode(to: stream)
        return stream.bytes
    }
}

extension StreamDecodableCollection {
    static func decode(from bytes: [UInt8]) async throws -> Self {
        let stream = InputByteStream(bytes)
        return try await Self.decode(from: stream)
    }
}

extension StreamEncodableCollection {
    func encode() async throws -> [UInt8] {
        let stream = OutputByteStream()
        try await self.encode(to: stream)
        return stream.bytes
    }
}

// MARK: Safe Array subscript

extension Extensions {
    subscript(safe index: Int) -> Element? {
        guard index < items.count else {
            return nil
        }
        return items[index]
    }
}

extension ClientHello.Extensions {
    subscript(safe index: Int) -> Element? {
        guard index < items.count else {
            return nil
        }
        return items[index]
    }
}

extension ServerHello.Extensions {
    subscript(safe index: Int) -> Element? {
        guard index < items.count else {
            return nil
        }
        return items[index]
    }
}
