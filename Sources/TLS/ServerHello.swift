import Stream

public struct ServerHello: Equatable {
    public let random: Random
    public let sessionId: SessionId // [0..32]
    public let ciperSuite: CiperSuite
    public let compressionMethod: CompressionMethod
    public let extensions: [Extension]

    public init(
        random: Random,
        sessionId: SessionId,
        ciperSuite: CiperSuite,
        compressionMethod: CompressionMethod,
        extensions: [Extension])
    {
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
        self.random = Random()
        self.sessionId = sessionId
        self.ciperSuite = ciperSuite
        self.compressionMethod = .none
        self.extensions = []
    }
}

extension ServerHello {
    public init<T: StreamReader>(from stream: T) throws {
        self.random = try Random(from: stream)
        self.sessionId = try SessionId(from: stream)
        self.ciperSuite = try CiperSuite(from: stream)
        self.compressionMethod = try CompressionMethod(from: stream)
        self.extensions = try [Extension](from: stream)
    }

    public func encode<T: StreamWriter>(to stream: T) throws {
        try random.encode(to: stream)
        try sessionId.encode(to: stream)
        try ciperSuite.encode(to: stream)
        try compressionMethod.encode(to: stream)
        try extensions.encode(to: stream)
    }
}
