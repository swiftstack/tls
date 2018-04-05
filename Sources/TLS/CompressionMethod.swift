import Stream

public enum CompressionMethod: UInt8 {
    case none = 0
}

extension Array where Element == CompressionMethod {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt8.self))

        var methods: [CompressionMethod] = []
        var remain = length
        while remain > 0 {
            methods.append(try CompressionMethod(from: stream))
            remain -= 1
        }

        self = methods
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(UInt8(count))
        for value in self {
            try value.encode(to: stream)
        }
    }
}

extension CompressionMethod {
    init<T: StreamReader>(from stream: T) throws {
        let rawMethod = try stream.read(UInt8.self)
        guard let method = CompressionMethod(rawValue: rawMethod) else {
            throw TLSError.invalidCompressionMethod
        }
        self = method
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(rawValue)
    }
}
