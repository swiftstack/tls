import Stream

extension Extension {
    public struct ServerName: Equatable {
        public struct Name: Equatable {
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

        public let values: [Name]

        public init(values: [Name]) {
            self.values = values
        }
    }
}

extension Extension.ServerName.Name {
    init<T: StreamReader>(from stream: T) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = NameType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        self.type = type

        let length = Int(try stream.read(UInt16.self).byteSwapped)
        self.value = try stream.read(count: length) { bytes in
            return String(decoding: bytes, as: UTF8.self)
        }
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(type.rawValue)
        try stream.write(UInt16(value.utf8.count).byteSwapped)
        try stream.write(value)
    }
}

extension Extension.ServerName {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt16.self).byteSwapped)

        self.values = try stream.withLimitedStream(by: length) { stream in
            var names = [Name]()
            while !stream.isEmpty {
                names.append(try Name(from: stream))
            }
            return names
        }
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.countingLength(as: UInt16.self) { stream in
            for value in values {
                try value.encode(to: stream)
            }
        }
    }
}
