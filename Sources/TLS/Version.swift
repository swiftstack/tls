import Stream

public enum Version: UInt16 {
    case tls10 = 0x0301
    case tls11 = 0x0302
    case tls12 = 0x0303
    case tls13 = 0x0304
}

extension Version {
    public var major: UInt8 {
        return UInt8(truncatingIfNeeded: (self.rawValue >> 8))
    }
    public var minor: UInt8 {
        return UInt8(truncatingIfNeeded: self.rawValue)
    }
}

extension Version {
    init(from stream: StreamReader) throws {
        let rawVersion = try stream.read(UInt16.self)
        guard let version = Version(rawValue: rawVersion) else {
            throw TLSError.invalidProtocolVerion
        }
        self = version
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}
