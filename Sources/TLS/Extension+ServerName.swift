import Stream

extension Extension {
    public struct ServerName: Equatable {
        public enum NameType: UInt8 {
            case hostName = 0
        }
        public let type: NameType
        public let value: String

        public init(type: NameType, value: String) {
            self.type = type
            self.value = value
        }
    }
}

extension Extension.ServerName {
    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = NameType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        self.type = type

        let length = Int(try stream.read(UInt16.self))
        self.value = try stream.read(count: length) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(type.rawValue)
        try stream.write(UInt16(value.utf8.count))
        try stream.write(value)
    }
}

extension Array where Element == Extension.ServerName {
    init(from stream: StreamReader) throws {
        self = try stream.withSubStream(sizedBy: UInt16.self) { stream in
            var names = [Element]()
            while !stream.isEmpty {
                names.append(try Element(from: stream))
            }
            return names
        }
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.withSubStream(sizedBy: UInt16.self) { stream in
            for value in self {
                try value.encode(to: stream)
            }
        }
    }
}
