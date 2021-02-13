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
    static func decode(from stream: StreamReader) async throws -> Self {
        let length = Int(try await stream.read(UInt8.self))
        guard length > 0 else {
            return .init(renegotiatedConnection: [])
        }
        let renegotiatedConnection = try await stream.read(count: length)
        return .init(renegotiatedConnection: renegotiatedConnection)
    }

    func encode(to stream: StreamWriter) async throws {
        guard renegotiatedConnection.count > 0 else {
            try await stream.write(UInt8(0))
            return
        }
        try await stream.write(UInt8(renegotiatedConnection.count))
        try await stream.write(renegotiatedConnection)
    }
}
