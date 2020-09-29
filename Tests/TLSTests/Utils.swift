import Stream
@testable import TLS

// MARK: Add simplified init(_ bytes: [UInt8]) throws

protocol StreamDecodable {
    init(from stream: StreamReader) throws
}

protocol StreamEncodable {
    func encode(to stream: StreamWriter) throws
}

protocol StreamCodable: StreamEncodable, StreamDecodable {}

extension ClientHello: StreamCodable {}
extension ServerHello: StreamCodable {}
extension Handshake: StreamCodable {}
extension Alert: StreamCodable {}
extension RecordLayer: StreamCodable {}
extension ClientKeyExchange: StreamCodable {}
extension Extension: StreamCodable {}
extension Extension.Heartbeat: StreamCodable {}
extension Extension.RenegotiationInfo: StreamCodable {}
extension Extension.ServerName: StreamCodable {}
extension Extension.StatusRequest: StreamCodable {}
extension ServerKeyExchange: StreamCodable {}
//extension Extension.SignatureAlgorithm: StreamCodable {}
//extension Extension.ECPointFormat: StreamCodable {}

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

extension Array where Element == Extension.ECPointFormat {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }

    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

extension Array where Element == Extension.ServerName {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }

    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

extension Array where Element == Extension.SignatureAlgorithm {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }

    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

extension Array where Element == Extension.SupportedGroup {
    init(_ bytes: [UInt8]) throws {
        let stream = InputByteStream(bytes)
        try self.init(from: stream)
    }

    func encode() throws -> [UInt8] {
        let stream = OutputByteStream()
        try self.encode(to: stream)
        return stream.bytes
    }
}

// MARK: Safe Array subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}
