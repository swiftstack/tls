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
    case finished(Finished)
    case newSessionTicket(NewSessionTicket)
    case keyUpdate

    case obsolete(Obsolete)
}

extension Handshake {
    fileprivate enum ContentType: UInt8 {
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

extension Handshake.ContentType {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = Handshake.ContentType(rawValue: rawType) else {
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
        guard let type = ContentType(rawValue: rawType) else {
            #if DEBUG
            return .obsolete(try await .decodeContent(
                rawType: rawType,
                from: stream))
            #else
            throw TLSError.invalidHandshakeType
            #endif
        }

        return try await stream.withSubStreamReader(
            sizedBy: UInt24.self
        ) { sub in
            switch type {
            case .clientHello:
                return .clientHello(try await .decode(from: sub))
            case .serverHello:
                return .serverHello(try await .decode(from: sub))
            case .newSessionTicket:
                return .newSessionTicket(try await .decode(from: sub))
            case .certificate:
                return .certificate(try await .decode(from: sub))
            case .certificateVerify:
                return .certificateVerify(try await .decode(from: sub))
            case .encryptedExtensions:
                return .encryptedExtensions(try await .decode(from: sub))
            case .finished:
                return .finished(try await .decode(from: sub))
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

        func write(_ type: ContentType) async throws {
            try await stream.write(type.rawValue)
        }

        switch self {
        case .clientHello: try await write(.clientHello)
        case .serverHello: try await write(.serverHello)
        case .newSessionTicket: try await write(.newSessionTicket)
        case .certificate: try await write(.certificate)
        case .certificateVerify: try await write(.certificateVerify)
        case .encryptedExtensions: try await write(.encryptedExtensions)
        case .finished: try await write(.finished)
        default: fatalError("not implemented")
        }

        func write(_ encodable: StreamEncodable) async throws {
            try await stream.withSubStreamWriter(sizedBy: UInt24.self) { sub in
                try await encodable.encode(to: sub)
            }
        }

        switch self {
        case .clientHello(let value): try await write(value)
        case .serverHello(let value): try await write(value)
        case .newSessionTicket(let value): try await write(value)
        case .certificate(let value): try await write(value)
        case .certificateVerify(let value): try await write(value)
        case .encryptedExtensions(let value): try await write(value)
        case .finished(let value): try await write(value)
        default: fatalError("not implemented")
        }
    }
}
