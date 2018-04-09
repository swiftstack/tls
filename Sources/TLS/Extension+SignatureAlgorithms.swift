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
        let length = Int(try stream.read(UInt16.self))

        var algorithms = [Element]()
        var remain = length
        while remain > 0 {
            let rawHash = try stream.read(UInt8.self)
            let rawSignature = try stream.read(UInt8.self)
            guard
                let hash = Element.Hash(rawValue: rawHash),
                let signature = Element.Signature(rawValue: rawSignature)
            else {
                throw TLSError.invalidExtension
            }
            algorithms.append(Element(hash: hash, signature: signature))
            remain -= MemoryLayout<UInt8>.size + MemoryLayout<UInt8>.size
        }
        self = algorithms
    }

    func encode(to stream: StreamWriter) throws {
        guard count > 0 else {
            return
        }
        try stream.countingLength(as: UInt16.self) { stream in
            for value in self {
                try stream.write(value.hash.rawValue)
                try stream.write(value.signature.rawValue)
            }
        }
    }
}
