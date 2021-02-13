import Stream

extension Extension {
    public struct ServerNames: Equatable {
        var items: [ServerName]

        init(_ items: [ServerName]) {
            self.items = items
        }
    }
}

extension Extension {
    public struct ServerName: Equatable {
        public enum NameType: UInt8 {
            case hostName = 0
        }
        public let type: NameType
        public let value: String

        public init(type: NameType, value: String) {
            self.type = type
            self.value = value
        }
    }
}

extension Extension.ServerName: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = NameType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        let length = Int(try await stream.read(UInt16.self))
        let value = try await stream.read(count: length) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }

        return .init(type: type, value: value)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(type.rawValue)
        try await stream.write(UInt16(value.utf8.count))
        try await stream.write(value)
    }
}

extension Extension.ServerNames: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extension.ServerNames: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.ServerName...) {
        self.init([Extension.ServerName](elements))
    }
}
