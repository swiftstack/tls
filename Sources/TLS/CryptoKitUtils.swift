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
