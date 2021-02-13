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
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = Handshake.RawType(rawValue: rawType) else {
            throw TLSError.invalidHandshake
        }
        return type
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(self.rawValue)
    }
}

extension Handshake {
    static func decode(from stream: StreamReader) async throws -> Self {
        let type = try await RawType.decode(from: stream)
        return try await stream.withSubStreamReader(sizedBy: UInt24.self)
        { stream in
            switch type {
            case .clientHello:
                return .clientHello(try await ClientHello.decode(from: stream))
            case .serverHello:
                return .serverHello(try await ServerHello.decode(from: stream))
            case .newSessionTicket:
                return .newSessionTicket(try await NewSessionTicket.decode(from: stream))
            case .certificate:
                return .certificate(try await [X509.Certificate].decode(from: stream))
            case .serverKeyExchange:
                return .serverKeyExchange(try await ServerKeyExchange.decode(from: stream))
            case .clientKeyExchange:
                return .clientKeyExchange(try await ClientKeyExchange.decode(from: stream))
            case .certificateStatus:
                return .certificateStatus(try await CertificateStatus.decode(from: stream))
            case .serverHelloDone:
                return .serverHelloDone
            default:
                throw TLSError.invalidHandshake
            }
        }
    }

    func encode(to stream: StreamWriter) async throws {
        func write(rawType type: RawType) async throws {
            try await type.encode(to: stream)
        }
        switch self {
        case .clientHello: try await write(rawType: .clientHello)
        case .serverHello: try await write(rawType: .serverHello)
        case .newSessionTicket: try await write(rawType: .newSessionTicket)
        case .certificate: try await write(rawType: .certificate)
        case .serverKeyExchange: try await write(rawType: .serverKeyExchange)
        case .clientKeyExchange: try await write(rawType: .clientKeyExchange)
        case .serverHelloDone: try await write(rawType: .serverHelloDone)
        default: fatalError("not implemented")
        }

        try await stream.withSubStreamWriter(sizedBy: UInt24.self) { stream in
            switch self {
            case .clientHello(let value): try await value.encode(to: stream)
            case .serverHello(let value): try await value.encode(to: stream)
            case .newSessionTicket(let value): try await value.encode(to: stream)
            case .certificate(let value): try await value.encode(to: stream)
            case .serverKeyExchange(let value): try await value.encode(to: stream)
            case .clientKeyExchange(let value): try await value.encode(to: stream)
            case .serverHelloDone: return
            default: fatalError("not implemented")
            }
        }
    }
}
