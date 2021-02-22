import Crypto
import Stream

public enum Handshake: Equatable {
    case clientHello(ClientHello)
    case serverHello(ServerHello)
    case endOfEarlyData
    case encryptedExtensions(EncryptedExtensions)
    case certificateRequest
    case certificate(Certificates)
    case certificateVerify(CertificateVerify)
    case finished([UInt8])
    case newSessionTicket(NewSessionTicket)
    case keyUpdate

    case obsolete(Obsolete)
}

extension Handshake {
    fileprivate enum RawType: UInt8 {
        case clientHello = 1
        case serverHello = 2
        case newSessionTicket = 4
        case endOfEarlyData = 5
        case encryptedExtensions = 8
        case certificate = 11
        case certificateRequest = 13
        case certificateVerify = 15
        case finished = 20
        case keyUpdate = 24
    }
}

extension Handshake.RawType {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = Handshake.RawType(rawValue: rawType) else {
            throw TLSError.invalidHandshakeType
        }
        return type
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(self.rawValue)
    }
}

extension Handshake {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = RawType(rawValue: rawType) else {
            #if DEBUG
            return .obsolete(try await .decodeContent(rawType: rawType, from: stream))
            #else
            throw TLSError.invalidHandshakeType
            #endif
        }

        return try await stream.withSubStreamReader(sizedBy: UInt24.self)
        { stream in
            switch type {
            case .clientHello:
                return .clientHello(try await .decode(from: stream))
            case .serverHello:
                return .serverHello(try await .decode(from: stream))
            case .newSessionTicket:
                return .newSessionTicket(try await .decode(from: stream))
            case .certificate:
                return .certificate(try await .decode(from: stream))
            case .certificateVerify:
                return .certificateVerify(try await .decode(from: stream))
            case .encryptedExtensions:
                return .encryptedExtensions(try await .decode(from: stream))
            case .finished:
                return .finished(try await stream.readUntilEnd())
            default:
                throw TLSError.invalidHandshake
            }
        }
    }

    func encode(to stream: StreamWriter) async throws {
        #if DEBUG
        if case let .obsolete(value) = self {
            try await value.encode(to: stream)
            return
        }
        #endif

        func write(rawType type: RawType) async throws {
            try await stream.write(type.rawValue)
        }

        switch self {
        case .clientHello: try await write(rawType: .clientHello)
        case .serverHello: try await write(rawType: .serverHello)
        case .newSessionTicket: try await write(rawType: .newSessionTicket)
        case .certificate: try await write(rawType: .certificate)
        case .certificateVerify: try await write(rawType: .certificateVerify)
        case .encryptedExtensions: try await write(rawType: .encryptedExtensions)
        case .finished: try await write(rawType: .finished)
        default: fatalError("not implemented")
        }

        try await stream.withSubStreamWriter(sizedBy: UInt24.self) { stream in
            switch self {
            case .clientHello(let value): try await value.encode(to: stream)
            case .serverHello(let value): try await value.encode(to: stream)
            case .newSessionTicket(let value): try await value.encode(to: stream)
            case .certificate(let value): try await value.encode(to: stream)
            case .certificateVerify(let value): try await value.encode(to: stream)
            case .encryptedExtensions(let value): try await value.encode(to: stream)
            case .finished(let value): try await stream.write(value)
            default: fatalError("not implemented")
            }
        }
    }
}
