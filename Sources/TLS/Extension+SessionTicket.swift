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
    init<T: StreamReader>(from stream: T) throws {
        self.data = try stream.readUntilEnd()
    }
}
