import Stream

public struct NewSessionTicket: Equatable {
    public let lifetime: Int
    public let ageAdd: Int
    public let nonce: [UInt8]
    public let ticket: [UInt8]
    public let earlyDataIndication: EarlyDataIndication?

    public struct EarlyDataIndication: Equatable {
        let maxSize: Int
    }
}

extension NewSessionTicket: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let lifetime = Int(try await stream.read(UInt32.self))
        let ageAdd = Int(try await stream.read(UInt32.self))

        let nonceLength = Int(try await stream.read(UInt8.self))
        let nonce = try await stream.read(count: nonceLength)

        let ticketLength = Int(try await stream.read(UInt16.self))
        let ticket = try await stream.read(count: ticketLength)

        let edi = try await EarlyDataIndication?.decode(from: stream)

        return .init(
            lifetime: lifetime,
            ageAdd: ageAdd,
            nonce: nonce,
            ticket: ticket,
            earlyDataIndication: edi)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt32(lifetime))
        try await stream.write(UInt32(ageAdd))

        try await stream.write(UInt8(nonce.count))
        try await stream.write(nonce)

        try await stream.write(UInt16(ticket.count))
        try await stream.write(ticket)

        try await earlyDataIndication.encode(to: stream)
    }
}

extension Optional where Wrapped == NewSessionTicket.EarlyDataIndication {
    static func decode(from stream: StreamReader) async throws -> Self {
        let length = try await stream.read(UInt16.self)
        guard length != 0 else {
            return nil
        }
        guard length == MemoryLayout<UInt32>.size else {
            throw TLSError.invalidEarlyDataIndication
        }
        let maxSize = Int(try await stream.read(UInt32.self))
        return .init(maxSize: maxSize)
    }

    func encode(to stream: StreamWriter) async throws {
        switch self {
        case .some(let edi):
            try await stream.write(UInt16(MemoryLayout<UInt32>.size))
            try await stream.write(UInt32(edi.maxSize))
        case .none:
            try await stream.write(UInt16(0))
        }
    }
}
