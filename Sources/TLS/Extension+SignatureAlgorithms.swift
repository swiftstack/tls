import Stream

extension Extension {
    public struct SignatureAlgorithm: Equatable {
        public enum Hash: UInt8 {
            case none   = 0x00
            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
            case md5    = 0x01
            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
            case sha1   = 0x02
            case sha224 = 0x03
            case sha256 = 0x04
            case sha384 = 0x05
            case sha512 = 0x06
        }

        public enum Signature: UInt8 {
            case anonymous = 0x00
            case rsa       = 0x01
            @available(*, deprecated, message: "insecure, removed in TLS 1.3")
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

extension Array where Element == Extension.SignatureAlgorithm {
    init(from stream: StreamReader) throws {
        self = try stream.withSubStream(sizedBy: UInt16.self) { stream in
            var algorithms = [Element]()
            while !stream.isEmpty {
                algorithms.append(try Element(from: stream))
            }
            return algorithms
        }
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.withSubStream(sizedBy: UInt16.self) { stream in
            for value in self {
                try value.encode(to: stream)
            }
        }
    }
}

extension Extension.SignatureAlgorithm {
    init(from stream: StreamReader) throws {
        let rawHash = try stream.read(UInt8.self)
        let rawSignature = try stream.read(UInt8.self)
        guard
            let hash = Hash(rawValue: rawHash),
            let signature = Signature(rawValue: rawSignature)
        else {
            throw TLSError.invalidExtension
        }
        self.hash = hash
        self.signature = signature
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(hash.rawValue)
        try stream.write(signature.rawValue)
    }
}
