import CryptoKit

func encrypt(
    _ bytes: UnsafeRawBufferPointer,
    using keys: PeerTrafficKeys,
    authenticating ad: [UInt8]
) throws -> [UInt8] {
    let cryptedBox = try AES.GCM.seal(
        bytes,
        using: keys.key,
        nonce: .init(data: keys.iv.nextIV),
        authenticating: ad)
    return [UInt8](cryptedBox.ciphertext + cryptedBox.tag)
}

func decrypt(
    _ bytes: UnsafeRawBufferPointer,
    using keys: PeerTrafficKeys,
    authenticating ad: [UInt8]
) throws -> [UInt8] {
    let sealedBox = try AES.GCM.SealedBox(
        nonce: .init(data: keys.iv.nextIV),
        ciphertext: bytes.dropLast(16),
        tag: bytes.suffix(16))
    return try AES.GCM.open(sealedBox, using: keys.key, authenticating: ad)
}

func encrypt(
    _ bytes: [UInt8],
    using keys: PeerTrafficKeys,
    authenticating ad: [UInt8]
) throws -> [UInt8] {
    try bytes.withUnsafeBytes { bytes in
        try encrypt(bytes, using: keys, authenticating: ad)
    }
}

func decrypt(
    _ bytes: [UInt8],
    using keys: PeerTrafficKeys,
    authenticating ad: [UInt8]
) throws -> [UInt8] {
    try bytes.withUnsafeBytes { bytes in
        try decrypt(bytes, using: keys, authenticating: ad)
    }
}
