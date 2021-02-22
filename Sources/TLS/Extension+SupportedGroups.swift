import Stream

extension Extension {
    public struct SupportedGroups: Equatable {
        var items: [SupportedGroup]

        init(_ items: [SupportedGroup]) {
            self.items = items
        }
    }
}

// https://tools.ietf.org/html/rfc8446#section-4.2.7

extension Extension {
    // ex elliptic_curves
    public enum SupportedGroup: RawRepresentable, Equatable {
        /* Elliptic Curve Groups (ECDHE) */
        case secp256r1
        case secp384r1
        case secp521r1
        case x25519
        case x448

        /* Finite Field Groups (DHE) */
        case ffdhe2048
        case ffdhe3072
        case ffdhe4096
        case ffdhe6144
        case ffdhe8192

        /* Reserved Code Points */
        case ffdhePrivateUse(UInt16) // 0x01FC..0x01FF
        case ecdhePrivateUse(UInt16) // 0xFE00..0xFEFF
        case reserved                // 0xFFFF

        case deprecated(Deprecated)

        public var rawValue: UInt16 {
            switch self {
            case .secp256r1: return Raw.secp256r1.rawValue
            case .secp384r1: return Raw.secp384r1.rawValue
            case .secp521r1: return Raw.secp521r1.rawValue
            case .x25519: return Raw.x25519.rawValue
            case .x448: return Raw.x448.rawValue

            case .ffdhe2048: return Raw.ffdhe2048.rawValue
            case .ffdhe3072: return Raw.ffdhe3072.rawValue
            case .ffdhe4096: return Raw.ffdhe4096.rawValue
            case .ffdhe6144: return Raw.ffdhe6144.rawValue
            case .ffdhe8192: return Raw.ffdhe8192.rawValue

            case .ffdhePrivateUse(let rawValue): return rawValue
            case .ecdhePrivateUse(let rawValue): return rawValue
            case .reserved: return 0xffff

            case .deprecated(let deprecated): return deprecated.rawValue
            }
        }

        public init?(rawValue: UInt16) {
            switch rawValue {
            case Raw.secp256r1.rawValue: self = .secp256r1
            case Raw.secp384r1.rawValue: self = .secp384r1
            case Raw.secp521r1.rawValue: self = .secp521r1
            case Raw.x25519.rawValue: self = .x25519
            case Raw.x448.rawValue: self = .x448

            case Raw.ffdhe2048.rawValue: self = .ffdhe2048
            case Raw.ffdhe3072.rawValue: self = .ffdhe3072
            case Raw.ffdhe4096.rawValue: self = .ffdhe4096
            case Raw.ffdhe6144.rawValue: self = .ffdhe6144
            case Raw.ffdhe8192.rawValue: self = .ffdhe8192

            case 0x01fc...0x01ff: self = .ffdhePrivateUse(rawValue)
            case 0xfe00...0xfeff: self = .ecdhePrivateUse(rawValue)
            case 0xffff: self = .reserved

            default:
                guard let deprecated = Deprecated(rawValue: rawValue) else {
                    return nil
                }
                self = .deprecated(deprecated)
            }
        }

        enum Raw: UInt16 {
            /* Elliptic Curve Groups (ECDHE) */
            case secp256r1 = 0x0017
            case secp384r1 = 0x0018
            case secp521r1 = 0x0019
            case x25519 = 0x001d
            case x448 = 0x001e

            /* Finite Field Groups (DHE) */
            case ffdhe2048 = 0x0100
            case ffdhe3072 = 0x0101
            case ffdhe4096 = 0x0102
            case ffdhe6144 = 0x0103
            case ffdhe8192 = 0x0104
        }

        // https://tools.ietf.org/html/rfc4492#section-5.1.1

        public enum Deprecated: UInt16 {
            /* Elliptic Curve Groups (ECDHE) */
            case sect163k1 = 0x0001
            case sect163r1 = 0x0002
            case sect163r2 = 0x0003
            case sect193r1 = 0x0004
            case sect193r2 = 0x0005
            case sect233k1 = 0x0006
            case sect233r1 = 0x0007
            case sect239k1 = 0x0008
            case sect283k1 = 0x0009
            case sect283r1 = 0x000a
            case sect409k1 = 0x000b
            case sect409r1 = 0x000c
            case sect571k1 = 0x000d
            case sect571r1 = 0x000e
            case secp160k1 = 0x000f
            case secp160r1 = 0x0010
            case secp160r2 = 0x0011
            case secp192k1 = 0x0012
            case secp192r1 = 0x0013
            case secp224k1 = 0x0014
            case secp224r1 = 0x0015
            case secp256k1 = 0x0016

            case brainpoolP256r1 = 0x001a
            case brainpoolP384r1 = 0x001b
            case brainpoolP512r1 = 0x001c

            /* Reserved Code Points */
            case arbitrary_explicit_prime_curves = 0xFF01
            case arbitrary_explicit_char2_curves = 0xFF02
        }
    }
}

extension Extension.SupportedGroup: StreamCodable {
    typealias SupportedGroup = Extension.SupportedGroup

    static func decode(from stream: StreamReader) async throws -> Self {
        let rawGroup = try await stream.read(UInt16.self)
        guard let group = SupportedGroup(rawValue: rawGroup) else {
            throw TLSError.invalidExtension
        }
        return group
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}

extension Extension.SupportedGroups: StreamCodableCollection {
    typealias LengthType = UInt16
}

extension Extension.SupportedGroups: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Extension.SupportedGroup...) {
        self.init([Extension.SupportedGroup](elements))
    }
}

extension Extension.SupportedGroup: CustomStringConvertible {
    public var description: String {
        switch self {
        case .secp256r1: return ".secp256r1"
        case .secp384r1: return ".secp384r1"
        case .secp521r1: return ".secp521r1"
        case .x25519: return ".x25519"
        case .x448: return ".x448"
        /* Finite Field Groups (DHE) */
        case .ffdhe2048: return ".ffdhe2048"
        case .ffdhe3072: return ".ffdhe3072"
        case .ffdhe4096: return ".ffdhe4096"
        case .ffdhe6144: return ".ffdhe6144"
        case .ffdhe8192: return ".ffdhe8192"
        /* Reserved Code Points */
        case .ffdhePrivateUse(let value): return ".ffdhePrivateUse(\(value))"
        case .ecdhePrivateUse(let value): return ".ecdhePrivateUse(\(value))"
        case .reserved: return ".reserved"

        case .deprecated(let value): return ".deprecated(\(value))"
        }
    }
}
