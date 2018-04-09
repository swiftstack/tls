import Stream

extension Extension {
    public struct SessionTicket: Equatable {
        public let data: [UInt8]

        public init(data: [UInt8]) {
            self.data = data
        }
    }
}

extension Extension.SessionTicket {
    init(from stream: StreamReader) throws {
        self.data = try stream.readUntilEnd()
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(data)
    }
}
