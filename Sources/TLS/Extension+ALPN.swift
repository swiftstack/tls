import Stream

extension Extension {
    public struct ALPN: Equatable {
        var items: [NextProtocol]

        init(_ items: [NextProtocol]) {
            self.items = items
        }
    }
}

extension Extension.ALPN {
    public enum NextProtocol: RawRepresentable, Equatable {
        case http2
        case http11
        case unkwnown(String)

        public var rawValue: String {
            switch self {
            case .http2: return "h2"
            case .http11: return "http/1.1"
            case .unkwnown(let value): return value
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "h2": self = .http2
            case "http/1.1": self = .http11
            default: self = .unkwnown(rawValue)
            }
        }
    }
}

extension Extension.ALPN.NextProtocol: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let length = Int(try await stream.read(UInt8.self))
        let value = try await stream.read(count: length) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
        return .init(rawValue: value)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt8(rawValue.utf8.count))
        try await stream.write(rawValue)
    }
}

extension Extension.ALPN: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extension.ALPN: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.ALPN.NextProtocol...) {
        self.init([Extension.ALPN.NextProtocol](elements))
    }
}
