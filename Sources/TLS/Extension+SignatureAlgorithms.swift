import Stream

extension Extension {
    public struct SignatureAlgorithms: Equatable {
        var items: [SignatureAlgorithm]

        init(_ items: [SignatureAlgorithm]) {
            self.items = items
        }
    }
}

extension Extension {
    public struct SignatureAlgorithm: Equatable {
        public enum Hash: UInt8 {
            case none   = 0x00
//            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
            case md5    = 0x01
//            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
            case sha1   = 0x02
            case sha224 = 0x03
            case sha256 = 0x04
            case sha384 = 0x05
            case sha512 = 0x06
        }

        public enum Signature: UInt8 {
            case anonymous = 0x00
            case rsa       = 0x01
//            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
            case dsa       = 0x02
            case ecdsa     = 0x03
        }

        public let hash: Hash
        public let signature: Signature

        public init(hash: Hash, signature: Signature) {
            self.hash = hash
            self.signature = signature
        }
    }
}

extension Extension.SignatureAlgorithm: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawHash = try await stream.read(UInt8.self)
        let rawSignature = try await stream.read(UInt8.self)
        guard
            let hash = Hash(rawValue: rawHash),
            let signature = Signature(rawValue: rawSignature)
        else {
            throw TLSError.invalidExtension
        }
        return .init(hash: hash, signature: signature)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(hash.rawValue)
        try await stream.write(signature.rawValue)
    }
}

extension Extension.SignatureAlgorithms: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extension.SignatureAlgorithms: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.SignatureAlgorithm...) {
        self.init([Extension.SignatureAlgorithm](elements))
    }
}
