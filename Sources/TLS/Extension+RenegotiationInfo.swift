import Stream

extension Extension {
    public struct RenegotiationInfo: Equatable {
        let renegotiatedConnection: [UInt8]

        public init(renegotiatedConnection: [UInt8] = []) {
            self.renegotiatedConnection = renegotiatedConnection
        }
    }
}

extension Extension.RenegotiationInfo {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt8.self))
        guard length > 0 else {
            self.renegotiatedConnection = []
            return
        }
        self.renegotiatedConnection = try stream.read(count: length)
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        guard renegotiatedConnection.count > 0 else {
            try stream.write(UInt8(0))
            return
        }
        try stream.write(UInt8(renegotiatedConnection.count))
        try stream.write(renegotiatedConnection)
    }
}
