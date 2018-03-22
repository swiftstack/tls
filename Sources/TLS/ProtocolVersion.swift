import Stream

public enum ProtocolVersion: UInt16 {
    case tls10 = 0x0301
    case tls11 = 0x0302
    case tls12 = 0x0303
}

extension ProtocolVersion {
    public var major: UInt8 {
        return UInt8(truncatingIfNeeded: (self.rawValue >> 8))
    }
    public var minor: UInt8 {
        return UInt8(truncatingIfNeeded: self.rawValue)
    }
}

extension ProtocolVersion {
    init<T: StreamReader>(from stream: T) throws {
        let rawVersion = try stream.read(UInt16.self).byteSwapped
        guard let version = ProtocolVersion(rawValue: rawVersion) else {
            throw TLSError.invalidProtocolVerion
        }
        self = version
    }
}
