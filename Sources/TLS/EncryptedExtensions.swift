import Stream

//+--------------------------------------------------+-------------+
//| Encrypted Extension                              |     TLS 1.3 |
//+--------------------------------------------------+-------------+
//| server_name [RFC6066]                            |      CH, EE |
//| max_fragment_length [RFC6066]                    |      CH, EE |
//| supported_groups [RFC7919]                       |      CH, EE |
//| use_srtp [RFC5764]                               |      CH, EE |
//| heartbeat [RFC6520]                              |      CH, EE |
//| application_layer_protocol_negotiation [RFC7301] |      CH, EE |
//| client_certificate_type [RFC7250]                |      CH, EE |
//| server_certificate_type [RFC7250]                |      CH, EE |
//| early_data (RFC 8446)                            | CH, EE, NST |
//+--------------------------------------------------+-------------+

public struct EncryptedExtensions: Equatable {
    var items: [Extension.Encrypted]

    init(_ items: [Extension.Encrypted]) {
        self.items = items
    }
}

extension Extension {
    public enum Encrypted: Equatable {
        case serverName(ServerName?)
        case recordSizeLimit(RecordSizeLimit)
        case supportedGroups(SupportedGroups)
        //case useSRTP(UseSRTP)
        case heartbeat(Heartbeat)
        case alpn(ALPN)
        //case clientCertificateType(ClientSertificateType)
        //case serverCertificateType(ServerSertificateType)
        //case earlyData(EarlyData)
        case obsolete(Obsolete)
        case unknown(Unknown)
    }
}

extension Extension.Encrypted: StreamDecodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        let length = Int(try await stream.read(UInt16.self))

        guard let type = Extension.RawType(rawValue: rawType) else {
            #if DEBUG
            let content = try await stream.read(count: Int(length))
            return .unknown(.init(rawType: rawType, content: content))
            #else
            throw TLSError.invalidEncryptedExtension
            #endif
        }

        // fast path to avoid extra InputStream + read() overhead
        guard length > 0 else {
            switch type {
            case .serverName:
                return .serverName(nil)
            default:
                 throw TLSError.invalidEncryptedExtension
            }
        }

        return try await stream.withSubStreamReader(limitedBy: length)
        { stream in
            switch type {
            case .serverName:
                return .serverName(try await .decode(from: stream))
            case .recordSizeLimit:
                return .recordSizeLimit(try await .decode(from: stream))
            case .supportedGroups:
                return .supportedGroups(try await .decode(from: stream))
            case .heartbeat:
                return .heartbeat(try await .decode(from: stream))
            case .alpn:
                return .alpn(try await .decode(from: stream))
            default:
                return .obsolete(try await .decodeContent(for: type, from: stream))
            }
        }
    }
}

extension Extension.Encrypted: StreamEncodable {
    func encode(to stream: StreamWriter) async throws {
        func write(_ rawType: Extension.RawType) async throws {
            try await stream.write(rawType.rawValue)
        }

        switch self {
        case .serverName: try await write(.serverName)
        case .recordSizeLimit: try await write(.recordSizeLimit)
        case .supportedGroups: try await write(.supportedGroups)
        case .heartbeat: try await write(.heartbeat)
        case .alpn: try await write(.alpn)
        default: return
        }

        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { stream in
            switch self {
            case .serverName(let .some(value)): try await value.encode(to: stream)
            case .recordSizeLimit(let value): try await value.encode(to: stream)
            case .supportedGroups(let value): try await value.encode(to: stream)
            case .heartbeat(let value): try await value.encode(to: stream)
            case .alpn(let value): try await value.encode(to: stream)
            default: return
            }
        }
    }
}

extension EncryptedExtensions: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension EncryptedExtensions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.Encrypted...) {
        self.init([Extension.Encrypted](elements))
    }
}
