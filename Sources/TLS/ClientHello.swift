import Stream

public struct ClientHello: Equatable {
    let version: ProtocolVersion
    let random: Random
    let sessionId: SessionId // [0..32]
    let ciperSuites: [CiperSuite]
    let compressionMethods: [CompressionMethod]
    let extensions: [Extension]

    public init(
        version: ProtocolVersion,
        random: Random,
        sessionId: SessionId,
        ciperSuites: [CiperSuite],
        compressionMethods: [CompressionMethod],
        extensions: [Extension])
    {
        self.version = version
        self.random = random
        self.sessionId = sessionId
        self.ciperSuites = ciperSuites
        self.compressionMethods = compressionMethods
        self.extensions = extensions
    }
}

extension ClientHello {
    public init<T: StreamReader>(from stream: T) throws {
        self.version = try ProtocolVersion(from: stream)
        self.random = try Random(from: stream)
        self.sessionId = try SessionId(from: stream)
        self.ciperSuites = try [CiperSuite](from: stream)
        self.compressionMethods = try [CompressionMethod](from: stream)
        self.extensions = try [Extension](from: stream)
    }

    public func encode<T: StreamWriter>(to stream: T) throws {
        try version.encode(to: stream)
        try random.encode(to: stream)
        try sessionId.encode(to: stream)
        try ciperSuites.encode(to: stream)
        try compressionMethods.encode(to: stream)
        try extensions.encode(to: stream)
    }
}
