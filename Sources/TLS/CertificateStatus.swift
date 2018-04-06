import Stream

extension Certificate {
    public enum StatusType: UInt8 {
        case ocsp = 0x01
    }
}

extension Certificate.StatusType {
    init<T: StreamReader>(from stream: T) throws {
        let rawStatus = try stream.read(UInt8.self)
        guard let type = Certificate.StatusType(rawValue: rawStatus) else {
            throw TLSError.invalidExtension
        }
        self = type
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(rawValue)
    }
}
