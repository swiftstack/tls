import Stream

public struct Alert: Equatable {
    public let level: Level
    public let description: Description

    public init(level: Level, description: Description) {
        self.level = level
        self.description = description
    }
}

extension Alert {
    public enum Level: UInt8 {
        case warning = 1
        case fatal = 2
    }

    public enum Description: UInt8 {
        case closeNotify = 0
        case unexpectedMessage = 10
        case badRecordMAC = 20
        case decryptionFailed = 21
        case recordOverflow = 22
        case decompressionFailure = 30
        case handshakeFailure = 40
        case noCertificateRESERVED = 41
        case badCertificate = 42
        case unsupportedCertificate = 43
        case certificateRevoked = 44
        case certificateExpired = 45
        case certificateUnknown = 46
        case illegalParameter = 47
        case unknownCA = 48
        case accessDenied = 49
        case decodeError = 50
        case decryptError = 51
        case exportRestrictionRESERVED = 60
        case protocolVersion = 70
        case insufficientSecurity = 71
        case internalError = 80
        case inappropriateFallback = 86
        case userCanceled = 90
        case noRenegotiation = 100
        case unsupportedExtension = 110
        case certificateUnobtainable = 111
        case unrecognizedName = 112
        case badCertificateStatusResponse = 113
        case badCertificateHashValue = 114
        case unknownPskIdentity = 115
    }
}

extension Alert {
    init(from stream: StreamReader) throws {
        let rawLevel = try stream.read(UInt8.self)
        let rawDescription = try stream.read(UInt8.self)

        guard let level = Level(rawValue: rawLevel),
            let description = Description(rawValue: rawDescription) else {
                throw TLSError.invalidAlert
        }

        self.level = level
        self.description = description
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(level.rawValue)
        try stream.write(description.rawValue)
    }
}
