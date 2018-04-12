import Stream

extension Extension {
    // ex elliptic_curves
    public enum SupportedGroup: UInt16 {
        /* Elliptic Curve Groups (ECDHE) */
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect163k1 = 0x0001
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect163r1 = 0x0002
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect163r2 = 0x0003
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect193r1 = 0x0004
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect193r2 = 0x0005
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect233k1 = 0x0006
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect233r1 = 0x0007
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect239k1 = 0x0008
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect283k1 = 0x0009
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect283r1 = 0x000a
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect409k1 = 0x000b
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect409r1 = 0x000c
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect571k1 = 0x000d
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case sect571r1 = 0x000e
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp160k1 = 0x000f
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp160r1 = 0x0010
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp160r2 = 0x0011
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp192k1 = 0x0012
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp192r1 = 0x0013
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp224k1 = 0x0014
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp224r1 = 0x0015
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case secp256k1 = 0x0016

        case secp256r1 = 0x0017 // available in TLS 1.3
        case secp384r1 = 0x0018 // available in TLS 1.3
        case secp521r1 = 0x0019 // available in TLS 1.3

        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case brainpoolP256r1 = 0x001a
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case brainpoolP384r1 = 0x001b
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case brainpoolP512r1 = 0x001c

        case x25519 = 0x001d // [draft-tls13][RFC-ietf-tls-rfc4492bis-17]
        case x448 = 0x001e // [draft-tls13][RFC-ietf-tls-rfc4492bis-17]

        /* Finite Field Groups (DHE) */
        case ffdhe2048 = 0x0100
        case ffdhe3072 = 0x0101
        case ffdhe4096 = 0x0102
        case ffdhe6144 = 0x0103
        case ffdhe8192 = 0x0104

        /* Reserved Code Points */
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case arbitrary_explicit_prime_curves = 0xFF01
        @available(*, deprecated, message: "insecure, removed in TLS 1.3")
        case arbitrary_explicit_char2_curves = 0xFF02
    }
}

extension Array where Element == Extension.SupportedGroup {
    init(from stream: StreamReader) throws {
        let length = Int(try stream.read(UInt16.self))

        var groups = [Element]()
        var remain = length
        while remain > 0 {
            groups.append(try Element(from: stream))
            remain -= MemoryLayout<UInt16>.size
        }
        self = groups
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

extension Extension.SupportedGroup {
    typealias SupportedGroup = Extension.SupportedGroup

    init(from stream: StreamReader) throws {
        let rawGroup = try stream.read(UInt16.self)
        guard let group = SupportedGroup(rawValue: rawGroup) else {
            throw TLSError.invalidExtension
        }
        self = group
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}
