import CryptoKit
import struct Foundation.Data

extension PrivateKey {
    func sharedSecret(with publicKey: PublicKey) throws -> SymmetricKey {
        return .init(data: try sharedSecretFromKeyAgreement(with: publicKey))
    }
}

extension HashFunction {
    func hmac(using key: SymmetricKey) -> HMAC<SHA256>.MAC {
        finalize().withUnsafeBytes { buffer in
            HMAC<SHA256>.authenticationCode(for: buffer, using: key)
        }
    }
}

extension HashedAuthenticationCode {
    func verify(with remote: [UInt8]) throws {
        guard withUnsafeBytes({ $0.elementsEqual(remote) }) else {
            throw TLSError.invalidTranscriptHash
        }
    }
}

extension AES.GCM {
    public static func open(
        _ sealedBox: AES.GCM.SealedBox,
        using key: SymmetricKey,
        authenticating ad: [UInt8]
    ) throws -> [UInt8] {
        let data: Data = try open(sealedBox, using: key, authenticating: ad)
        return .init(data)
    }

    public static func open(
        _ sealedBox: AES.GCM.SealedBox,
        using key: SymmetricKey,
        authenticating ad: UnsafeRawBufferPointer
    ) throws -> [UInt8] {
        let data: Data = try open(sealedBox, using: key, authenticating: ad)
        return .init(data)
    }
}

// MARK: @testable

extension SymmetricKey {
    var bytes: [UInt8] {
        self.withUnsafeBytes { [UInt8]($0) }
    }
}

extension SymmetricKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        self.init(data: parse(string))
    }
}

extension PrivateKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

extension PublicKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

// parse hex string from rfc examples
func parse(_ string: String) -> [UInt8] {
    .init(decodingHex: string.filter { !$0.isWhitespace })!
}
