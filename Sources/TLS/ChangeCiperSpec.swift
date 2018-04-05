import Stream

public enum ChangeCiperSpec: UInt8 {
    case `default` = 1
}

extension ChangeCiperSpec {
    init<T: StreamReader>(from stream: T) throws {
        let rawSpec = try stream.read(UInt8.self)
        guard let spec = ChangeCiperSpec(rawValue: rawSpec) else {
            throw TLSError.invalidChangeCiperSpec
        }
        self = spec
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(rawValue)
    }
}
