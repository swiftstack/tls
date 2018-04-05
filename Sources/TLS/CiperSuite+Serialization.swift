import Stream

extension Array where Element == CiperSuite {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt16.self).byteSwapped)
        guard length % 2 == 0 else {
            throw TLSError.invalidCiperSuitesLength
        }

        var ciperSuites: [CiperSuite] = []
        var remain = length
        while remain > 0 {
            ciperSuites.append(try CiperSuite(from: stream))
            remain -= 2
        }
        self = ciperSuites
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(UInt16(count << 1).byteSwapped)
        for value in self {
            try value.encode(to: stream)
        }
    }
}

extension CiperSuite {
    init<T: StreamReader>(from stream: T) throws {
        let rawCiperSuite = try stream.read(UInt16.self).byteSwapped
        guard let ciperSuite = CiperSuite(rawValue: rawCiperSuite) else {
            throw TLSError.invalidCiperSuite
        }
        self = ciperSuite
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(rawValue.byteSwapped)
    }
}
