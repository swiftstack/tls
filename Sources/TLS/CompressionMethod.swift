import Stream

public enum CompressionMethod: UInt8 {
    case none = 0
}

extension Array where Element == CompressionMethod {
    init(from stream: StreamReader) throws {
        let length = Int(try stream.read(UInt8.self))

        var methods: [CompressionMethod] = []
        var remain = length
        while remain > 0 {
            methods.append(try CompressionMethod(from: stream))
            remain -= 1
        }

        self = methods
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.write(UInt8(count))
        for value in self {
            try value.encode(to: stream)
        }
    }
}

extension CompressionMethod {
    init(from stream: StreamReader) throws {
        let rawMethod = try stream.read(UInt8.self)
        guard let method = CompressionMethod(rawValue: rawMethod) else {
            throw TLSError.invalidCompressionMethod
        }
        self = method
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}
