import Stream

public struct ClientHello: Equatable {
    let version: Version
    let random: Random
    let sessionId: SessionId // [0..32]
    let ciperSuites: CiperSuites
    let compressionMethods: CompressionMethods
    let extensions: Extensions

    public init(
        version: Version,
        random: Random,
        sessionId: SessionId,
        ciperSuites: CiperSuites,
        compressionMethods: CompressionMethods,
        extensions: Extensions
    ) {
        self.version = version
        self.random = random
        self.sessionId = sessionId
        self.ciperSuites = ciperSuites
        self.compressionMethods = compressionMethods
        self.extensions = extensions
    }
}

extension ClientHello {
    public static func decode(from stream: StreamReader) async throws -> Self {
        return .init(
            version: try await Version.decode(from: stream),
            random: try await Random.decode(from: stream),
            sessionId: try await SessionId.decode(from: stream),
            ciperSuites: try await CiperSuites.decode(from: stream),
            compressionMethods: try await CompressionMethods.decode(from: stream),
            extensions: try await Extensions.decode(from: stream))
    }

    public func encode(to stream: StreamWriter) async throws {
        try await version.encode(to: stream)
        try await random.encode(to: stream)
        try await sessionId.encode(to: stream)
        try await ciperSuites.encode(to: stream)
        try await compressionMethods.encode(to: stream)
        try await extensions.encode(to: stream)
    }
}
