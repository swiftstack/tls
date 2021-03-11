import CryptoKit

public typealias PublicKey = Curve25519.KeyAgreement.PublicKey
public typealias PrivateKey = Curve25519.KeyAgreement.PrivateKey

struct PeerTrafficKeys: Equatable {
    let key: SymmetricKey
    let iv: PerRecordNonce
}

struct TrafficKeys: Equatable {
    let read: PeerTrafficKeys
    let write: PeerTrafficKeys
}

struct SymmetricKeys {
    let read: SymmetricKey
    let write: SymmetricKey
}

struct HandshakeKeys {
    var traffic: TrafficKeys
    let finished: SymmetricKeys
    let master: SymmetricKey
}

struct HandshakeDerivedKeys {
    let master: SymmetricKey
    let trafficSecrets: SymmetricKeys
}

struct Keys<H: HashFunction> {
    static var earlySecret: SymmetricKey {
        .init(data: HKDF<H>.extract(
            inputKeyMaterial: .zeros,
            salt: []))
    }

    static var earlyDigest: H.Digest {
        H.hash(data: [])
    }

    static var derivedForHandshakeSecret: SymmetricKey {
        let result = HKDF<H>.deriveKey(
            inputKeyMaterial: earlySecret,
            label: .derived,
            digest: earlyDigest)
        return result
    }

    static func handshakeSecret(
        sharedSecret: SymmetricKey
    ) -> SymmetricKey {
        let hash = derivedForHandshakeSecret.withUnsafeBytes {
            HKDF<H>.extract(inputKeyMaterial: sharedSecret, salt: $0)
        }
        return .init(data: hash)
    }

    static func clientHSTrafficSecret(
        handshakeSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> SymmetricKey {
        let result = HKDF<H>.deriveKey(
            inputKeyMaterial: handshakeSecret,
            label: .clientHandshakeTraffic,
            digest: hash)
        return result
    }

    static func serverHSTrafficSecret(
        handshakeSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> SymmetricKey {
        let result = HKDF<H>.deriveKey(
            inputKeyMaterial: handshakeSecret,
            label: .serverHandshakeTraffic,
            digest: hash)
        return result
    }

    static func derivedForMasterSecret(
        handshakeSecret: SymmetricKey
    ) -> SymmetricKey {
        HKDF<H>.deriveKey(
            inputKeyMaterial: handshakeSecret,
            label: .derived,
            digest: earlyDigest)
    }

    static func masterSecret(
        handshakeSecret: SymmetricKey
    ) -> SymmetricKey {
        let salt = derivedForMasterSecret(
            handshakeSecret: handshakeSecret)
        let code = salt.withUnsafeBytes {
            HKDF<H>.extract(inputKeyMaterial: .zeros, salt: $0)
        }
        return .init(data: code)
    }

    static func peerTrafficKeys(secret: SymmetricKey) -> PeerTrafficKeys {
        let key = HKDF<H>.expandLabel(
            pseudoRandomKey: secret,
            label: .key,
            context: [],
            length: 16)

        let iv = HKDF<H>.expandLabel(
            pseudoRandomKey: secret,
            label: .iv,
            context: [],
            length: 12)

        let prn = PerRecordNonce(baseIV: iv.withUnsafeBytes { [UInt8]($0) })
        return .init(key: key, iv: prn)
    }

    static func finishedSecret(secret: SymmetricKey) -> SymmetricKey {
        HKDF<H>.expandLabel(
            pseudoRandomKey: secret,
            label: .finished,
            context: [],
            length: 32)
    }

    static func clientTrafficSecret(
        masterSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> SymmetricKey {
        let result = HKDF<H>.deriveKey(
            inputKeyMaterial: masterSecret,
            label: .clientApplicationTraffic,
            digest: hash)
        return result
    }

    static func serverTrafficSecret(
        masterSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> SymmetricKey {
        let result = HKDF<H>.deriveKey(
            inputKeyMaterial: masterSecret,
            label: .serverApplicationTraffic,
            digest: hash)
        return result
    }
}

extension Keys {
    static func handshakeKeys(
        sharedSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> HandshakeKeys {
        let handshakeSecret = Keys<H>.handshakeSecret(
            sharedSecret: sharedSecret)

        let serverTrafficSecret = Keys<H>.serverHSTrafficSecret(
            handshakeSecret: handshakeSecret,
            transcriptHash: hash)

        let clientTrafficSecret = Keys<H>.clientHSTrafficSecret(
            handshakeSecret: handshakeSecret,
            transcriptHash: hash)

        let trafficKeys = TrafficKeys(
            read: Keys<H>.peerTrafficKeys(secret: serverTrafficSecret),
            write: Keys<H>.peerTrafficKeys(secret: clientTrafficSecret))

        let finishedKeys = SymmetricKeys(
            read: Keys<H>.finishedSecret(secret: serverTrafficSecret),
            write: Keys<H>.finishedSecret(secret: clientTrafficSecret))

        let master = Keys<H>.masterSecret(handshakeSecret: handshakeSecret)

        return .init(
            traffic: trafficKeys,
            finished: finishedKeys,
            master: master)
    }

    static func applicationTrafficSecrets(
        masterSecret: SymmetricKey,
        transcriptHash hash: H.Digest
    ) -> SymmetricKeys {
        let serverTrafficSecret = Keys<H>.serverTrafficSecret(
            masterSecret: masterSecret,
            transcriptHash: hash)

        let clientTrafficSecret = Keys<H>.clientTrafficSecret(
            masterSecret: masterSecret,
            transcriptHash: hash)

        return .init(
            read: serverTrafficSecret,
            write: clientTrafficSecret)
    }

    static func applicationTrafficKeys(
        trafficSecrets: SymmetricKeys
    ) -> TrafficKeys {
        return .init(
            read: Keys<H>.peerTrafficKeys(secret: trafficSecrets.read),
            write: Keys<H>.peerTrafficKeys(secret: trafficSecrets.write))
    }
}

extension SymmetricKey {
    static let zeros = SymmetricKey(data: [UInt8](repeating: 0, count: 32))
}
