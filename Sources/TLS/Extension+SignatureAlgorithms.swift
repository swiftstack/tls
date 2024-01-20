import Stream

extension Extension {
    public struct SignatureAlgorithms: Equatable {
        var items: [SignatureAlgorithm]

        init(_ items: [SignatureAlgorithm]) {
            self.items = items
        }
    }
}

// https://tools.ietf.org/html/rfc8446#section-4.2.3

extension Extension {
    public enum SignatureAlgorithm: RawRepresentable, Equatable {
        case rsa_pkcs1_sha256
        case rsa_pkcs1_sha384
        case rsa_pkcs1_sha512
        /* ECDSA algorithms */
        case ecdsa_secp256r1_sha256
        case ecdsa_secp384r1_sha384
        case ecdsa_secp521r1_sha512
        /* RSASSA-PSS algorithms with public key OID rsaEncryption */
        case rsa_pss_rsae_sha256
        case rsa_pss_rsae_sha384
        case rsa_pss_rsae_sha512
        /* EdDSA algorithms */
        case ed25519
        case ed448
        /* RSASSA-PSS algorithms with public key OID RSASSA-PSS */
        case rsa_pss_pss_sha256
        case rsa_pss_pss_sha384
        case rsa_pss_pss_sha512
        /* Legacy algorithms */
        case rsa_pkcs1_sha1
        case ecdsa_sha1
        /* backward compatibility */
        case unknown(UInt16)

        public var rawValue: UInt16 {
            switch self {
            case .rsa_pkcs1_sha256:
                return Raw.rsa_pkcs1_sha256.rawValue
            case .rsa_pkcs1_sha384:
                return Raw.rsa_pkcs1_sha384.rawValue
            case .rsa_pkcs1_sha512:
                return Raw.rsa_pkcs1_sha512.rawValue
            case .ecdsa_secp256r1_sha256:
                return Raw.ecdsa_secp256r1_sha256.rawValue
            case .ecdsa_secp384r1_sha384:
                return Raw.ecdsa_secp384r1_sha384.rawValue
            case .ecdsa_secp521r1_sha512:
                return Raw.ecdsa_secp521r1_sha512.rawValue
            case .rsa_pss_rsae_sha256:
                return Raw.rsa_pss_rsae_sha256.rawValue
            case .rsa_pss_rsae_sha384:
                return Raw.rsa_pss_rsae_sha384.rawValue
            case .rsa_pss_rsae_sha512:
                return Raw.rsa_pss_rsae_sha512.rawValue
            case .ed25519:
                return Raw.ed25519.rawValue
            case .ed448:
                return Raw.ed448.rawValue
            case .rsa_pss_pss_sha256:
                return Raw.rsa_pss_pss_sha256.rawValue
            case .rsa_pss_pss_sha384:
                return Raw.rsa_pss_pss_sha384.rawValue
            case .rsa_pss_pss_sha512:
                return Raw.rsa_pss_pss_sha512.rawValue
            case .rsa_pkcs1_sha1:
                return Raw.rsa_pkcs1_sha1.rawValue
            case .ecdsa_sha1:
                return Raw.ecdsa_sha1.rawValue
            case .unknown(let value):
                return value
            }
        }

        public init(rawValue: UInt16) {
            switch rawValue {
            case Raw.rsa_pkcs1_sha256.rawValue:
                self = .rsa_pkcs1_sha256
            case Raw.rsa_pkcs1_sha384.rawValue:
                self = .rsa_pkcs1_sha384
            case Raw.rsa_pkcs1_sha512.rawValue:
                self = .rsa_pkcs1_sha512
            case Raw.ecdsa_secp256r1_sha256.rawValue:
                self = .ecdsa_secp256r1_sha256
            case Raw.ecdsa_secp384r1_sha384.rawValue:
                self = .ecdsa_secp384r1_sha384
            case Raw.ecdsa_secp521r1_sha512.rawValue:
                self = .ecdsa_secp521r1_sha512
            case Raw.rsa_pss_rsae_sha256.rawValue:
                self = .rsa_pss_rsae_sha256
            case Raw.rsa_pss_rsae_sha384.rawValue:
                self = .rsa_pss_rsae_sha384
            case Raw.rsa_pss_rsae_sha512.rawValue:
                self = .rsa_pss_rsae_sha512
            case Raw.ed25519.rawValue:
                self = .ed25519
            case Raw.ed448.rawValue:
                self = .ed448
            case Raw.rsa_pss_pss_sha256.rawValue:
                self = .rsa_pss_pss_sha256
            case Raw.rsa_pss_pss_sha384.rawValue:
                self = .rsa_pss_pss_sha384
            case Raw.rsa_pss_pss_sha512.rawValue:
                self = .rsa_pss_pss_sha512
            case Raw.rsa_pkcs1_sha1.rawValue:
                self = .rsa_pkcs1_sha1
            case Raw.ecdsa_sha1.rawValue:
                self = .ecdsa_sha1
            default:
                self = .unknown(rawValue)
            }
        }

        public enum Raw: UInt16 {
            case rsa_pkcs1_sha256 = 0x0401
            case rsa_pkcs1_sha384 = 0x0501
            case rsa_pkcs1_sha512 = 0x0601
            /* ECDSA algorithms */
            case ecdsa_secp256r1_sha256 = 0x0403
            case ecdsa_secp384r1_sha384 = 0x0503
            case ecdsa_secp521r1_sha512 = 0x0603
            /* RSASSA-PSS algorithms with public key OID rsaEncryption */
            case rsa_pss_rsae_sha256 = 0x0804
            case rsa_pss_rsae_sha384 = 0x0805
            case rsa_pss_rsae_sha512 = 0x0806
            /* EdDSA algorithms */
            case ed25519 = 0x0807
            case ed448 = 0x0808
            /* RSASSA-PSS algorithms with public key OID RSASSA-PSS */
            case rsa_pss_pss_sha256 = 0x0809
            case rsa_pss_pss_sha384 = 0x080a
            case rsa_pss_pss_sha512 = 0x080b
            /* Legacy algorithms */
            case rsa_pkcs1_sha1 = 0x0201
            case ecdsa_sha1 = 0x0203
        }

        /* Reserved Code Points */
        // case private_use(0xFE00..0xFFFF),

        private enum Hash: UInt8 {
            case none   = 0x00
            case md5    = 0x01
            case sha1   = 0x02
            case sha224 = 0x03
            case sha256 = 0x04
            case sha384 = 0x05
            case sha512 = 0x06
            case unknown = 0xff
        }

        private enum Signature: UInt8 {
            case anonymous = 0x00
            case rsa       = 0x01
            case dsa       = 0x02
            case ecdsa     = 0x03
            case ed25519   = 0x07
            case ed448     = 0x08
            case unknown   = 0xff
        }
    }
}

extension Extension.SignatureAlgorithm: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawValue = try await stream.read(UInt16.self)
        return Self(rawValue: rawValue)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
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

extension Extension.SignatureAlgorithm: CustomStringConvertible {
    public var description: String {
        switch self {
        case .rsa_pkcs1_sha256: return ".rsa_pkcs1_sha256"
        case .rsa_pkcs1_sha384: return ".rsa_pkcs1_sha384"
        case .rsa_pkcs1_sha512: return ".rsa_pkcs1_sha512"
        /* ECDSA algorithms */
        case .ecdsa_secp256r1_sha256: return ".ecdsa_secp256r1_sha256"
        case .ecdsa_secp384r1_sha384: return ".ecdsa_secp384r1_sha384"
        case .ecdsa_secp521r1_sha512: return ".ecdsa_secp521r1_sha512"
        /* RSASSA-PSS algorithms with public key OID rsaEncryption */
        case .rsa_pss_rsae_sha256: return ".rsa_pss_rsae_sha256"
        case .rsa_pss_rsae_sha384: return ".rsa_pss_rsae_sha384"
        case .rsa_pss_rsae_sha512: return ".rsa_pss_rsae_sha512"
        /* EdDSA algorithms */
        case .ed25519: return ".ed25519"
        case .ed448: return ".ed448"
        /* RSASSA-PSS algorithms with public key OID RSASSA-PSS */
        case .rsa_pss_pss_sha256: return ".rsa_pss_pss_sha256"
        case .rsa_pss_pss_sha384: return ".rsa_pss_pss_sha384"
        case .rsa_pss_pss_sha512: return ".rsa_pss_pss_sha512"
        /* Legacy algorithms */
        case .rsa_pkcs1_sha1: return ".rsa_pkcs1_sha1"
        case .ecdsa_sha1: return ".ecdsa_sha1"

        case .unknown(let value): return ".unknown(\(value))"
        }
    }
}
