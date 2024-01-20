import Stream

// https://tools.ietf.org/html/rfc8446#section-4.2

// +--------------------------------------------------+-------------+
// | Client Hello Extension                           |     TLS 1.3 |
// +--------------------------------------------------+-------------+
// | server_name [RFC6066]                            |      CH, EE |
// | max_fragment_length [RFC6066]                    |      CH, EE |
// | status_request [RFC6066]                         |  CH, CR, CT |
// | supported_groups [RFC7919]                       |      CH, EE |
// | signature_algorithms (RFC 8446)                  |      CH, CR |
// | use_srtp [RFC5764]                               |      CH, EE |
// | heartbeat [RFC6520]                              |      CH, EE |
// | application_layer_protocol_negotiation [RFC7301] |      CH, EE |
// | signed_certificate_timestamp [RFC6962]           |  CH, CR, CT |
// | client_certificate_type [RFC7250]                |      CH, EE |
// | server_certificate_type [RFC7250]                |      CH, EE |
// | padding [RFC7685]                                |          CH |
// | key_share (RFC 8446)                             | CH, SH, HRR |
// | pre_shared_key (RFC 8446)                        |      CH, SH |
// | psk_key_exchange_modes (RFC 8446)                |          CH |
// | early_data (RFC 8446)                            | CH, EE, NST |
// | cookie (RFC 8446)                                |     CH, HRR |
// | supported_versions (RFC 8446)                    | CH, SH, HRR |
// | certificate_authorities (RFC 8446)               |      CH, CR |
// | post_handshake_auth (RFC 8446)                   |          CH |
// | signature_algorithms_cert (RFC 8446)             |      CH, CR |
// +--------------------------------------------------+-------------+

extension ClientHello {
    public typealias ServerNames = TLS.Extension.ServerNames
    public typealias SupportedGroups = TLS.Extension.SupportedGroups
    public typealias SignatureAlgorithms = TLS.Extension.SignatureAlgorithms
    public typealias Heartbeat = TLS.Extension.Heartbeat
    public typealias ALPN = TLS.Extension.ALPN
    public typealias RecordSizeLimit = TLS.Extension.RecordSizeLimit
    public typealias SupportedVersions = TLS.Extension.SupportedVersions
    public typealias PSKKeyExchangeModes = TLS.Extension.PSKKeyExchangeModes
    public typealias PostHandshakeAuth = TLS.Extension.PostHandshakeAuth
    public typealias KeysShare = TLS.Extension.KeysShare
    public typealias Obsolete = TLS.Extension.Obsolete
    public typealias Unknown = TLS.Extension.Unknown

    public struct Extensions: Equatable {
        var items: [Extension]

        init(_ items: [Extension]) {
            self.items = items
        }
    }

    public enum Extension: Equatable {
        case serverName(ServerNames)
        case supportedGroups(SupportedGroups)
        case signatureAlgorithms(SignatureAlgorithms)
        case heartbeat(Heartbeat)
        case alpn(ALPN)
        case recordSizeLimit(RecordSizeLimit)
        case supportedVersions(SupportedVersions)
        case pskKeyExchangeModes(PSKKeyExchangeModes)
        case postHandshakeAuth(PostHandshakeAuth)
        case keyShare(KeysShare)
        case obsolete(Obsolete)
        case unknown(Unknown)
    }
}

extension ClientHello.Extension: StreamDecodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        let length = Int(try await stream.read(UInt16.self))

        guard let type = Extension.RawType(rawValue: rawType) else {
            #if DEBUG
            let content = try await stream.read(count: Int(length))
            return .unknown(.init(rawType: rawType, content: content))
            #else
            throw TLSError.invalidExtension
            #endif
        }
        // fast path to avoid extra InputStream + read() overhead
        guard length > 0 else {
            switch type {
            case .serverName:
                return .serverName([])
            case .supportedGroups:
                return .supportedGroups([])
            case .signatureAlgorithms:
                return .signatureAlgorithms([])
            case .heartbeat:
                throw TLSError.invalidClientHelloExtension
            case .alpn:
                return .alpn([])
            case .supportedVersions:
                return .supportedVersions([])
            case .postHandshakeAuth:
                return .postHandshakeAuth(.init())
            default:
                return .obsolete(try .empty(rawType: type))
            }
        }

        return try await stream.withSubStreamReader(limitedBy: length) { sub in
            switch type {
            case .serverName:
                return .serverName(try await .decode(from: sub))
            case .supportedGroups:
                return .supportedGroups(try await .decode(from: sub))
            case .signatureAlgorithms:
                return .signatureAlgorithms(try await .decode(from: sub))
            case .heartbeat:
                return .heartbeat(try await .decode(from: sub))
            case .alpn:
                return .alpn(try await .decode(from: sub))
            case .recordSizeLimit:
                return .recordSizeLimit(try await .decode(from: sub))
            case .supportedVersions:
                return .supportedVersions(try await .decode(from: sub))
            case .pskKeyExchangeModes:
                return .pskKeyExchangeModes(try await .decode(from: sub))
            case .postHandshakeAuth:
                return .postHandshakeAuth(try await .decode(from: sub))
            case .keyShare:
                return .keyShare(try await .decode(from: sub))
            default:
                return .obsolete(try await .decodeContent(for: type, from: sub))
            }
        }
    }
}

extension ClientHello.Extension: StreamEncodable {
    func encode(to stream: StreamWriter) async throws {
        func write(_ rawType: TLS.Extension.RawType) async throws {
            try await stream.write(rawType.rawValue)
        }

        switch self {
        case .serverName:
            try await write(.serverName)
        case .supportedGroups:
            try await write(.supportedGroups)
        case .signatureAlgorithms:
            try await write(.signatureAlgorithms)
        case .heartbeat:
            try await write(.heartbeat)
        case .alpn:
            try await write(.alpn)
        case .recordSizeLimit:
            try await write(.recordSizeLimit)
        case .supportedVersions:
            try await write(.supportedVersions)
        case .pskKeyExchangeModes:
            try await write(.pskKeyExchangeModes)
        case .postHandshakeAuth:
            try await write(.postHandshakeAuth)
        case .keyShare:
            try await write(.keyShare)
        case .obsolete: throw TLSError.invalidClientHelloExtension
        case .unknown: throw TLSError.invalidClientHelloExtension
        }

        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { sub in
            switch self {
            case .serverName(let value):
                try await value.encode(to: sub)
            case .supportedGroups(let value):
                try await value.encode(to: sub)
            case .signatureAlgorithms(let value):
                try await value.encode(to: sub)
            case .heartbeat(let value):
                try await value.encode(to: sub)
            case .alpn(let value):
                try await value.encode(to: sub)
            case .recordSizeLimit(let value):
                try await value.encode(to: sub)
            case .supportedVersions(let value):
                try await value.encode(to: sub)
            case .pskKeyExchangeModes(let value):
                try await value.encode(to: sub)
            case .postHandshakeAuth(let value):
                try await value.encode(to: sub)
            case .keyShare(let value):
                try await value.encode(to: sub)
            case .obsolete:
                throw TLSError.invalidClientHelloExtension
            case .unknown:
                throw TLSError.invalidClientHelloExtension
            }
        }
    }
}

extension ClientHello.Extensions: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension ClientHello.Extensions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: ClientHello.Extension...) {
        self.init([ClientHello.Extension](elements))
    }
}
