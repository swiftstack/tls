import Stream

public struct Certificate: Equatable {
    public let bytes: [UInt8]
}

extension Array where Element == Certificate {
    init(from stream: StreamReader) throws {
        self = try stream.withSubStream(sizedBy: UInt24.self) { stream in
            var certificates = [Certificate]()
            while !stream.isEmpty {
                certificates.append(try Certificate(from: stream))
            }
            return certificates
        }
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.withSubStream(sizedBy: UInt24.self) { stream in
            for value in self {
                try value.encode(to: stream)
            }
        }
    }
}

extension Certificate {
    init(from stream: StreamReader) throws {
        let length = Int(try stream.read(UInt24.self))
        self.bytes = try stream.read(count: length)
    }

    func encode(to stream: StreamWriter) throws {
        try stream.withSubStream(sizedBy: UInt24.self) { stream in
            try stream.write(bytes)
        }
    }
}
