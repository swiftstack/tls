import Stream

public struct Extensions: Equatable {
    var items: [Extension.Obsolete]

    init(_ items: [Extension.Obsolete]) {
        self.items = items
    }
}

public enum Extension: Equatable {
    // prior to TLS 1.3
    public enum Obsolete: Equatable {
        case ecPointFormats(ECPointFormats)
        case sessionTicket(SessionTicket)
        case statusRequest(StatusRequest)
        case encryptThenMac(EncryptThenMac)
        case extendedMasterSecret(ExtendedMasterSecret)
        case nextProtocolNegotiation(NextProtocolNegotiation)
        case renegotiationInfo(RenegotiationInfo)
    }
}

extension Extension.Obsolete: StreamDecodable {
    static func decodeContent(
        for type: Extension.RawType,
        from stream: StreamReader
    ) async throws -> Self {
        switch type {
        case .ecPointFormats:
            return .ecPointFormats(try await .decode(from: stream))
        case .sessionTicket:
            return .sessionTicket(try await .decode(from: stream))
        case .statusRequest:
            return .statusRequest(try await .decode(from: stream))
        case .encryptThenMac:
            return .encryptThenMac(try await .decode(from: stream))
        case .extendedMasterSecret:
            return .extendedMasterSecret(try await .decode(from: stream))
        case .renegotiationInfo:
            return .renegotiationInfo(try await .decode(from: stream))
        case .nextProtocolNegotiation:
            return .nextProtocolNegotiation(try await .decode(from: stream))
        default:
            throw TLSError.invalidExtension
        }
    }

    static func empty(rawType type: Extension.RawType) throws -> Self {
        switch type {
        case .ecPointFormats:
            return .ecPointFormats([])
        case .sessionTicket:
            return .sessionTicket(.init(data: []))
        case .statusRequest:
            return .statusRequest(.none)
        case .heartbeat:
            throw TLSError.invalidExtension
        case .encryptThenMac:
            return .encryptThenMac(.init())
        case .extendedMasterSecret:
            return .extendedMasterSecret(.init())
        case .nextProtocolNegotiation:
            return .nextProtocolNegotiation(.none)
        case .renegotiationInfo:
            return .renegotiationInfo(.init())
        default:
            throw TLSError.invalidExtension
        }
    }

    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt16.self)
        let length = Int(try await stream.read(UInt16.self))

        guard let type = Extension.RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }

        // fast path to avoid extra InputStream + read() overhead
        guard length > 0 else {
            return try empty(rawType: type)
        }

        return try await stream.withSubStreamReader(limitedBy: length) { sub in
            try await decodeContent(for: type, from: sub)
        }
    }
}

extension Extension.Obsolete: StreamEncodable {
    func encode(to stream: StreamWriter) async throws {
        func write(_ rawType: Extension.RawType) async throws {
            try await stream.write(rawType.rawValue)
        }

        switch self {
        case .ecPointFormats:
            try await write(.ecPointFormats)
        case .sessionTicket:
            try await write(.sessionTicket)
        case .statusRequest:
            try await write(.statusRequest)
        case .encryptThenMac:
            try await write(.encryptThenMac)
        case .extendedMasterSecret:
            try await write(.extendedMasterSecret)
        case .nextProtocolNegotiation:
            try await write(.nextProtocolNegotiation)
        case .renegotiationInfo:
            try await write(.renegotiationInfo)
        }

        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { sub in
            switch self {
            case .ecPointFormats(let value):
                try await value.encode(to: sub)
            case .sessionTicket(let value):
                try await value.encode(to: sub)
            case .statusRequest(let value):
                try await value.encode(to: sub)
            case .encryptThenMac(let value):
                try await value.encode(to: sub)
            case .extendedMasterSecret(let value):
                try await value.encode(to: sub)
            case .nextProtocolNegotiation(let value):
                try await value.encode(to: sub)
            case .renegotiationInfo(let value):
                try await value.encode(to: sub)
            }
        }
    }
}

extension Extensions: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extensions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.Obsolete...) {
        self.init([Extension.Obsolete](elements))
    }
}
