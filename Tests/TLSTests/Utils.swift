import Stream
@testable import TLS

// MARK: Add simplified init(_ bytes: [UInt8]) throws

extension ClientHello: StreamCodable {}
extension ServerHello: StreamCodable {}
extension Handshake: StreamCodable {}
extension Alert: StreamCodable {}
extension RecordLayer: StreamCodable {}
extension ClientKeyExchange: StreamCodable {}
extension Extension.Heartbeat: StreamCodable {}
extension Extension.RenegotiationInfo: StreamCodable {}
extension Extension.StatusRequest: StreamCodable {}
extension ServerKeyExchange: StreamCodable {}

extension StreamDecodable {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }
}

extension StreamEncodable {
    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

extension StreamDecodableCollection {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }
}

extension StreamEncodableCollection {
    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

// MARK: Safe Array subscript

extension Extensions {
    subscript(safe index: Int) -> Element? {
        guard index < items.count else {
            return nil
        }
        return items[index]
    }
}
