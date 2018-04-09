import Stream

public enum Extension: Equatable {
    case serverName([ServerName])
    case supportedGroups([SupportedGroup])
    case ecPointFormats([ECPointFormat])
    case sessionTicket(SessionTicket)
    case signatureAlgorithms([SignatureAlgorithm])
    case statusRequest(StatusRequest)
    case heartbeat(Heartbeat)
    case renegotiationInfo(RenegotiationInfo)
}

extension Array where Element == Extension {
    init(from stream: StreamReader) throws {
        self = try stream.withSubStream(sizedBy: UInt16.self) { stream in
            var extensions = [Extension]()
            while !stream.isEmpty {
                extensions.append(try Extension(from: stream))
            }
            return extensions
        }
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.withSubStream(sizedBy: UInt16.self) { stream in
            for value in self {
                try value.encode(to: stream)
            }
        }
    }
}

extension Extension {
    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt16.self)
        let length = Int(try stream.read(UInt16.self))

        guard let type = RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        // fast path to avoid extra InputStream + read() overhead
        guard length > 0 else {
            switch type {
            case .serverName:
                self = .serverName([])
            case .supportedGroups:
                self = .supportedGroups([])
            case .ecPointFormats:
                self = .ecPointFormats([])
            case .sessionTicket:
                self = .sessionTicket(SessionTicket(data: []))
            case .signatureAlgorithms:
                self = .signatureAlgorithms([])
            case .statusRequest:
                self = .statusRequest(.none)
            case .heartbeat:
                throw TLSError.invalidExtension
            case .renegotiationInfo:
                self = .renegotiationInfo(RenegotiationInfo())
            default:
                throw TLSError.invalidExtension
            }
            return
        }

        self = try stream.withSubStream(limitedBy: length) { stream in
            switch type {
            case .serverName:
                return .serverName(try [ServerName](from: stream))
            case .supportedGroups:
                return .supportedGroups(try [SupportedGroup](from: stream))
            case .ecPointFormats:
                return .ecPointFormats(try [ECPointFormat](from: stream))
            case .sessionTicket:
                return .sessionTicket(try SessionTicket(from: stream))
            case .signatureAlgorithms:
                return .signatureAlgorithms(try [SignatureAlgorithm](from: stream))
            case .statusRequest:
                return .statusRequest(try StatusRequest(from: stream))
            case .heartbeat:
                return .heartbeat(try Heartbeat(from: stream))
            case .renegotiationInfo:
                return .renegotiationInfo(try RenegotiationInfo(from: stream))
            default:
                throw TLSError.invalidExtension
            }
        }
    }
}

extension Extension {
    func encode(to stream: StreamWriter) throws {
        func write(_ rawType: RawType) throws {
            try stream.write(rawType.rawValue)
        }

        switch self {
        case .serverName: try write(.serverName)
        case .supportedGroups: try write(.supportedGroups)
        case .ecPointFormats: try write(.ecPointFormats)
        case .sessionTicket: try write(.sessionTicket)
        case .signatureAlgorithms: try write(.signatureAlgorithms)
        case .statusRequest: try write(.statusRequest)
        case .heartbeat: try write(.heartbeat)
        case .renegotiationInfo: try write(.renegotiationInfo)
        }

        try stream.withSubStream(sizedBy: UInt16.self) { stream in
            switch self {
            case .serverName(let value): try value.encode(to: stream)
            case .supportedGroups(let value): try value.encode(to: stream)
            case .ecPointFormats(let value): try value.encode(to: stream)
            case .sessionTicket(let value): try value.encode(to: stream)
            case .signatureAlgorithms(let value): try value.encode(to: stream)
            case .statusRequest(let value): try value.encode(to: stream)
            case .heartbeat(let value): try value.encode(to: stream)
            case .renegotiationInfo(let value): try value.encode(to: stream)
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
