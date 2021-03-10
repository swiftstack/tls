import Crypto
import Stream

extension Handshake {
    public enum Obsolete: Equatable {
        case helloRequest
        case helloVerifyRequest
        case serverKeyExchange(ServerKeyExchange)
        case newSessionTicket(NewSessionTicket)
        case serverHelloDone
        case clientKeyExchange(ClientKeyExchange)
        case certificateUrl
        case certificateStatus(CertificateStatus)
        case supplementalData
    }
}

extension Handshake.Obsolete {
    fileprivate enum RawType: UInt8 {
        case helloRequest = 0
        case helloVerifyRequest = 3
        case serverKeyExchange = 12
        case serverHelloDone = 14
        case clientKeyExchange = 16
        case certificateUrl = 21
        case certificateStatus = 22
        case supplementalData = 23
    }
}

extension Handshake.Obsolete {
    static func decodeContent(
        rawType: UInt8,
        from stream: StreamReader) async throws -> Self
    {
        guard let type = RawType(rawValue: rawType) else {
            throw TLSError.invalidHandshakeType
        }
        return try await stream.withSubStreamReader(sizedBy: UInt24.self)
        { stream in
            switch type {
            case .serverKeyExchange:
                return .serverKeyExchange(try await .decode(from: stream))
            case .clientKeyExchange:
                return .clientKeyExchange(try await .decode(from: stream))
            case .certificateStatus:
                return .certificateStatus(try await .decode(from: stream))
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
        case .serverKeyExchange: try await write(rawType: .serverKeyExchange)
        case .clientKeyExchange: try await write(rawType: .clientKeyExchange)
        case .serverHelloDone: try await write(rawType: .serverHelloDone)
        case .certificateStatus: try await write(rawType: .certificateStatus)
        default: fatalError("not implemented")
        }

        func write(_ encodable: StreamEncodable) async throws {
            try await stream.withSubStreamWriter(sizedBy: UInt24.self)
            { stream in
                try await encodable.encode(to: stream)
            }
        }
        switch self {
        case .serverKeyExchange(let value): try await write(value)
        case .clientKeyExchange(let value): try await write(value)
        case .certificateStatus(let value): try await write(value)
        case .serverHelloDone: try await stream.write(UInt24(0))
        default: fatalError("not implemented")
        }
    }
}
