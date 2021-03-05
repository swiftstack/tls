import Stream

// https://tools.ietf.org/html/rfc8446#section-4.2.8

extension Extension {
    public struct KeysShare: Equatable {
        var items: [KeyShare]

        init(_ items: [KeyShare]) {
            self.items = items
        }
    }
}

extension Extension {
    public struct KeyShare: Equatable {
        public enum NamedGroup: UInt16 {
            case x25519 = 0x001d
        }
        public let group: NamedGroup
        public let keyExchange: PublicKey

        public init(group: NamedGroup, keyExchange: PublicKey) {
            self.group = group
            self.keyExchange = keyExchange
        }
    }
}

extension Extension.KeyShare: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        guard let group = NamedGroup(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        let length = Int(try await stream.read(UInt16.self))
        let rawKey = try await stream.read(count: length)
        let publicKey = try PublicKey(rawRepresentation: rawKey)

        return .init(group: group, keyExchange: publicKey)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(group.rawValue)
        try await stream.write(UInt16(keyExchange.bytes.count))
        try await stream.write(keyExchange.bytes)
    }
}

extension Extension.KeysShare: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extension.KeysShare: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.KeyShare...) {
        self.init([Extension.KeyShare](elements))
    }
}
