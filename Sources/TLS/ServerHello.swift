import Stream

public struct ServerHello: Equatable {
    public let version: Version
    public let random: Random
    public let sessionId: SessionId // [0..32]
    public let ciperSuite: CiperSuite
    public let compressionMethod: CompressionMethod
    public let extensions: Extensions

    var publicKey: PublicKey? {
        guard let keyShare = extensions.keyShare else { return nil }
        return keyShare.keyExchange
    }

    public init(
        version: Version,
        random: Random,
        sessionId: SessionId,
        ciperSuite: CiperSuite,
        compressionMethod: CompressionMethod,
        extensions: Extensions)
    {
        self.version = version
        self.random = random
        self.sessionId = sessionId
        self.ciperSuite = ciperSuite
        self.compressionMethod = compressionMethod
        self.extensions = extensions
    }
}

extension ServerHello {
    public init(ciperSuite: CiperSuite) {
        self.init(sessionId: SessionId(data: []), ciperSuite: ciperSuite)
    }

    public init(sessionId: SessionId, ciperSuite: CiperSuite) {
        self.version = .tls12
        self.random = Random()
        self.sessionId = sessionId
        self.ciperSuite = ciperSuite
        self.compressionMethod = .none
        self.extensions = .init()
    }
}

extension ServerHello {
    public static func decode(from stream: StreamReader) async throws -> Self {
        return .init(
            version: try await Version.decode(from: stream),
            random: try await Random.decode(from: stream),
            sessionId: try await SessionId.decode(from: stream),
            ciperSuite: try await CiperSuite.decode(from: stream),
            compressionMethod: try await CompressionMethod.decode(from: stream),
            extensions: try await Extensions.decode(from: stream))
    }

    public func encode(to stream: StreamWriter) async throws {
        try await version.encode(to: stream)
        try await random.encode(to: stream)
        try await sessionId.encode(to: stream)
        try await ciperSuite.encode(to: stream)
        try await compressionMethod.encode(to: stream)
        try await extensions.encode(to: stream)
    }
}
