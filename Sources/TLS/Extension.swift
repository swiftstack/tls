import Stream

public struct Extensions: Equatable {
    var items: [Extension]

    init(_ items: [Extension]) {
        self.items = items
    }
}

public enum Extension: Equatable {
    case serverName(ServerNames)
    case supportedGroups(SupportedGroups)
    case ecPointFormats(ECPointFormats)
    case sessionTicket(SessionTicket)
    case signatureAlgorithms(SignatureAlgorithms)
    case statusRequest(StatusRequest)
    case heartbeat(Heartbeat)
    case renegotiationInfo(RenegotiationInfo)
}


extension Extension: StreamDecodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        let length = Int(try await stream.read(UInt16.self))

        guard let type = RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        // fast path to avoid extra InputStream + read() overhead
        guard length > 0 else {
            switch type {
            case .serverName:
                return .serverName([])
            case .supportedGroups:
                return .supportedGroups([])
            case .ecPointFormats:
                return .ecPointFormats([])
            case .sessionTicket:
                return .sessionTicket(SessionTicket(data: []))
            case .signatureAlgorithms:
                return .signatureAlgorithms([])
            case .statusRequest:
                return .statusRequest(.none)
            case .heartbeat:
                throw TLSError.invalidExtension
            case .renegotiationInfo:
                return .renegotiationInfo(RenegotiationInfo())
            default:
                throw TLSError.invalidExtension
            }
        }

        return try await stream.withSubStreamReader(limitedBy: length)
        { stream in
            switch type {
            case .serverName:
                return .serverName(try await .decode(from: stream))
            case .supportedGroups:
                return .supportedGroups(try await .decode(from: stream))
            case .ecPointFormats:
                return .ecPointFormats(try await .decode(from: stream))
            case .sessionTicket:
                return .sessionTicket(try await .decode(from: stream))
            case .signatureAlgorithms:
                return .signatureAlgorithms(try await .decode(from: stream))
            case .statusRequest:
                return .statusRequest(try await .decode(from: stream))
            case .heartbeat:
                return .heartbeat(try await .decode(from: stream))
            case .renegotiationInfo:
                return .renegotiationInfo(try await .decode(from: stream))
            default:
                throw TLSError.invalidExtension
            }
        }
    }
}

extension Extension: StreamEncodable {
    func encode(to stream: StreamWriter) async throws {
        func write(_ rawType: RawType) async throws {
            try await stream.write(rawType.rawValue)
        }

        switch self {
        case .serverName: try await write(.serverName)
        case .supportedGroups: try await write(.supportedGroups)
        case .ecPointFormats: try await write(.ecPointFormats)
        case .sessionTicket: try await write(.sessionTicket)
        case .signatureAlgorithms: try await write(.signatureAlgorithms)
        case .statusRequest: try await write(.statusRequest)
        case .heartbeat: try await write(.heartbeat)
        case .renegotiationInfo: try await write(.renegotiationInfo)
        }

        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { stream in
            switch self {
            case .serverName(let value): try await value.encode(to: stream)
            case .supportedGroups(let value): try await value.encode(to: stream)
            case .ecPointFormats(let value): try await value.encode(to: stream)
            case .sessionTicket(let value): try await value.encode(to: stream)
            case .signatureAlgorithms(let value): try await value.encode(to: stream)
            case .statusRequest(let value): try await value.encode(to: stream)
            case .heartbeat(let value): try await value.encode(to: stream)
            case .renegotiationInfo(let value): try await value.encode(to: stream)
            }
        }
    }
}

extension Extension {
    fileprivate enum RawType: UInt16 {
        case serverName = 0x0000
        case maxFragmentLength = 0x0001
        case clientCertificateUrl = 0x0002
        case trustedCAKeys = 0x0003
        case truncatedHMAC = 0x0004
        case statusRequest = 0x0005
        case userMapping = 0x0006
        case clientAuthz = 0x0007
        case serverAuthz = 0x0008
        case certType = 0x0009
        case supportedGroups = 0x000a // (ex "elliptic_curves")
        case ecPointFormats = 0x000b
        case srp = 0x000c
        case signatureAlgorithms = 0x000d
        case useSrtp = 0x000e
        case heartbeat = 0x000f
        case applicationLayerProtocolNegotiation = 0x0010
        case statusRequestV2 = 0x0011
        case signedCertificateTimestamp = 0x0012
        case clientCertificateType = 0x0013
        case serverCertificateType = 0x0014
        case padding = 0x0015
        case encryptThenMac = 0x0016
        case extendedMasterSecret = 0x0017
        case tokenBinding = 0x0018 // (TEMPORARY - registered 2016-02-04, expires 2017-02-04)
        case cachedInfo  = 0x0019
        case sessionTicket = 0x0023
        case renegotiationInfo = 0xFF01
    }
}

extension Extensions: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extensions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension...) {
        self.init([Extension](elements))
    }
}

// TODO: Implement BidirectionalCollection protocol

extension Extensions {
    var count: Int { items.count }
}
