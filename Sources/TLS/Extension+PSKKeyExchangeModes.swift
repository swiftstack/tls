import Stream

// https://tools.ietf.org/html/rfc8446#section-4.2.9

extension Extension {
    public struct PSKKeyExchangeModes: Equatable {
        var items: [PSKKeyExchangeMode]

        init(_ items: [PSKKeyExchangeMode]) {
            self.items = items
        }
    }
}

extension Extension {
    public enum PSKKeyExchangeMode: UInt8, Equatable {
        case psk_ke = 0
        case psk_dhe_ke = 1
    }
}

extension Extension.PSKKeyExchangeMode: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawMode = try await stream.read(UInt8.self)
        guard let mode = Self(rawValue: rawMode) else {
            throw TLSError.invalidExtension
        }
        return mode
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}

extension Extension.PSKKeyExchangeModes: StreamCodableCollection {
    typealias LengthType = UInt8
}

extension Extension.PSKKeyExchangeModes: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.PSKKeyExchangeMode...) {
        self.init([Extension.PSKKeyExchangeMode](elements))
    }
}
