import Crypto
import Stream

public enum Handshake: Equatable {
    case helloRequest
    case clientHello(ClientHello)
    case serverHello(ServerHello)
    case helloVerifyRequest
    case newSessionTicket(NewSessionTicket)
    case certificate([X509.Certificate])
    case serverKeyExchange(ServerKeyExchange)
    case certificateRequest
    case serverHelloDone
    case certificateVerify
    case clientKeyExchange(ClientKeyExchange)
    case finished
    case certificateUrl
    case certificateStatus(CertificateStatus)
    case supplementalData
}

extension Handshake {
    fileprivate enum RawType: UInt8 {
        case helloRequest = 0
        case clientHello = 1
        case serverHello = 2
        case helloVerifyRequest = 3
        case newSessionTicket = 4
        case certificate = 11
        case serverKeyExchange = 12
        case certificateRequest = 13
        case serverHelloDone = 14
        case sertificateVerify = 15
        case clientKeyExchange = 16
        case finished = 20
        case certificateUrl = 21
        case certificateStatus = 22
        case supplementalData = 23
    }
}

extension Handshake.RawType {
    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = Handshake.RawType(rawValue: rawType) else {
            throw TLSError.invalidHandshake
        }
        self = type
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(self.rawValue)
    }
}

extension Handshake {
    init(from stream: StreamReader) throws {
        let type = try RawType(from: stream)
        self = try stream.withSubStream(sizedBy: UInt24.self) { stream in
            switch type {
            case .clientHello:
                return .clientHello(try ClientHello(from: stream))
            case .serverHello:
                return .serverHello(try ServerHello(from: stream))
            case .newSessionTicket:
                return .newSessionTicket(try NewSessionTicket(from: stream))
            case .certificate:
                return .certificate(try [X509.Certificate](from: stream))
            case .serverKeyExchange:
                return .serverKeyExchange(try ServerKeyExchange(from: stream))
            case .clientKeyExchange:
                return .clientKeyExchange(try ClientKeyExchange(from: stream))
            case .certificateStatus:
                return .certificateStatus(try CertificateStatus(from: stream))
            case .serverHelloDone:
                return .serverHelloDone
            default:
                throw TLSError.invalidHandshake
            }
        }
    }

    func encode(to stream: StreamWriter) throws {
        func write(rawType type: RawType) throws {
            try type.encode(to: stream)
        }
        switch self {
        case .clientHello: try write(rawType: .clientHello)
        case .serverHello: try write(rawType: .serverHello)
        case .newSessionTicket: try write(rawType: .newSessionTicket)
        case .certificate: try write(rawType: .certificate)
        case .serverKeyExchange: try write(rawType: .serverKeyExchange)
        case .clientKeyExchange: try write(rawType: .clientKeyExchange)
        case .serverHelloDone: try write(rawType: .serverHelloDone)
        default: fatalError("not implemented")
        }

        try stream.withSubStream(sizedBy: UInt24.self) { stream in
            switch self {
            case .clientHello(let value): try value.encode(to: stream)
            case .serverHello(let value): try value.encode(to: stream)
            case .newSessionTicket(let value): try value.encode(to: stream)
            case .certificate(let value): try value.encode(to: stream)
            case .serverKeyExchange(let value): try value.encode(to: stream)
            case .clientKeyExchange(let value): try value.encode(to: stream)
            case .serverHelloDone: return
            default: fatalError("not implemented")
            }
        }
    }
}
