import Stream

extension Extension {
    public struct ECPointFormats: Equatable {
        typealias LengthType = UInt8

        var items: [ECPointFormat]

        init(_ items: [ECPointFormat]) {
            self.items = items
        }
    }
}

extension Extension {
    public enum ECPointFormat: UInt8 {
        case uncompressed = 0x00
        case ansiX962_compressed_prime = 0x01
        case ansiX962_compressed_char2 = 0x02
    }
}

// MARK: Codable

extension Extension.ECPointFormat: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawPoint = try await stream.read(UInt8.self)
        guard let ecPoint = Self(rawValue: rawPoint) else {
            throw TLSError.invalidExtension
        }
        return ecPoint
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}

extension Extension.ECPointFormats: StreamCodableCollection { }

// MARK: Utils

extension Extension.ECPointFormats: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.ECPointFormat...) {
        self.init([Extension.ECPointFormat](elements))
    }
}
