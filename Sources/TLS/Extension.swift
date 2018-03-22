import Stream

public enum Extension: Equatable {
    case serverName(ServerName)
    case supportedGroups(SupportedGroups)
    case ecPointFormats(ECPointFormats)
    case sessionTicket(SessionTicket)
    case signatureAlgorithms(SignatureAlgorithms)
    case statusRequest(StatusRequest)
    case heartbeat(Heartbeat)
    case renegotiationInfo(RenegotiationInfo)
}

extension Array where Element == Extension {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt16.self).byteSwapped)
        self = try stream.withLimitedStream(by: length) { stream in
            var extensions = [Extension]()
            while !stream.isEmpty {
                extensions.append(try Extension(from: stream))
            }
            return extensions
        }
    }
}

extension Extension {
    init<T: StreamReader>(from stream: T) throws {
        let rawType = try stream.read(UInt16.self).byteSwapped
        let length = Int(try stream.read(UInt16.self).byteSwapped)

        guard let type = RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        // fast path to avoid extra InputByteStream init + read overhead
        guard length > 0 else {
            switch type {
            case .serverName:
                self = .serverName(ServerName(values: []))
            case .supportedGroups:
                self = .supportedGroups(SupportedGroups(values: []))
            case .ecPointFormats:
                self = .ecPointFormats(ECPointFormats(values: []))
            case .sessionTicket:
                self = .sessionTicket(SessionTicket(data: []))
            case .signatureAlgorithms:
                self = .signatureAlgorithms(SignatureAlgorithms(values: []))
            case .statusRequest:
                self = .statusRequest(StatusRequest(certificateStatus: nil))
            case .heartbeat:
                throw TLSError.invalidExtension
            case .renegotiationInfo:
                self = .renegotiationInfo(RenegotiationInfo(values: []))
            default:
                throw TLSError.invalidExtension
            }
            return
        }

        self = try stream.withLimitedStream(by: length) { stream in
            switch type {
            case .serverName:
                return .serverName(try ServerName(from: stream))
            case .supportedGroups:
                return .supportedGroups(try SupportedGroups(from: stream))
            case .ecPointFormats:
                return .ecPointFormats(try ECPointFormats(from: stream))
            case .sessionTicket:
                return .sessionTicket(try SessionTicket(from: stream))
            case .signatureAlgorithms:
                return .signatureAlgorithms(try SignatureAlgorithms(from: stream))
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
        case supportedGroups = 0x000a // (renamed from "elliptic_curves")
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
