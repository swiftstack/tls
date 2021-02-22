import Stream

// https://tools.ietf.org/html/rfc8446#section-4.2

//+--------------------------------------------------+-------------+
//| Server Hello Extension                           |     TLS 1.3 |
//+--------------------------------------------------+-------------+
//| key_share (RFC 8446)                             | CH, SH, HRR |
//| pre_shared_key (RFC 8446)                        |      CH, SH |
//| supported_versions (RFC 8446)                    | CH, SH, HRR |
//+--------------------------------------------------+-------------+

extension ServerHello {
    public typealias KeyShare = TLS.Extension.KeyShare
    public typealias Obsolete = TLS.Extension.Obsolete
    public typealias Unknown = TLS.Extension.Unknown

    public struct Extensions: Equatable {
        var items: [Extension]

        init(_ items: [Extension]) {
            self.items = items
        }

        public init(supportedVersions: Version = .tls13, keyShare: KeyShare) {
            var items = [Extension]()
            items.append(.supportedVersions(supportedVersions))
            items.append(.keyShare(keyShare))
            self.items = items
        }

        var supportedVersions: Version? {
            for next in items {
                if case let .supportedVersions(version) = next {
                    return version
                }
            }
            return nil
        }

        var keyShare: KeyShare? {
            for next in items {
                if case let .keyShare(keyShare) = next {
                    return keyShare
                }
            }
            return nil
        }
    }

    public enum Extension: Equatable {
        case supportedVersions(Version)
        case keyShare(KeyShare)
        case obsolete(Obsolete)
        case unknown(Unknown)
    }
}

extension ServerHello.Extension: StreamDecodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        let length = Int(try await stream.read(UInt16.self))

        guard let type = Extension.RawType(rawValue: rawType) else {
            #if DEBUG
            let content = try await stream.read(count: Int(length))
            return .unknown(.init(rawType: rawType, content: content))
            #else
            throw TLSError.invalidServerHelloExtension
            #endif
        }

        return try await stream.withSubStreamReader(limitedBy: length)
        { stream in
            switch type {
            case .supportedVersions:
                return .supportedVersions(try await .decode(from: stream))
            case .keyShare:
                return .keyShare(try await .decode(from: stream))
            default:
                return .obsolete(try await .decodeContent(for: type, from: stream))
            }
        }
    }
}

extension ServerHello.Extension: StreamEncodable {
    func encode(to stream: StreamWriter) async throws {
        func write(_ rawType: TLS.Extension.RawType) async throws {
            try await stream.write(rawType.rawValue)
        }

        switch self {
        case .supportedVersions: try await write(.supportedVersions)
        case .keyShare: try await write(.keyShare)
        default: throw TLSError.invalidServerHelloExtension
        }

        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { stream in
            switch self {
            case .supportedVersions(let value): try await value.encode(to: stream)
            case .keyShare(let value): try await value.encode(to: stream)
            default: throw TLSError.invalidServerHelloExtension
            }
        }
    }
}

extension ServerHello.Extensions: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension ServerHello.Extensions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: ServerHello.Extension...) {
        self.init([ServerHello.Extension](elements))
    }
}
