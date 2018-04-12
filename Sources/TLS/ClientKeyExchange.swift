import Stream

public struct ClientKeyExchange: Equatable {
    public let pubkey: [UInt8]

    public init(pubkey: [UInt8]) {
        self.pubkey = pubkey
    }
}

extension ClientKeyExchange {
    init(from stream: StreamReader) throws {
        let length = Int(try stream.read(UInt8.self))
        self.pubkey = try stream.read(count: length)
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(UInt8(pubkey.count))
        try stream.write(pubkey)
    }
}
