import Hex
import Test
import CryptoKit

@testable import TLS

enum Shared {}
enum Client {}
enum Server {}

typealias HASH = SHA256
typealias HMAC = CryptoKit.HMAC
typealias Nonce = CryptoKit.AES.GCM.Nonce
typealias PrivateKey = Curve25519.KeyAgreement.PrivateKey
typealias PublicKey = Curve25519.KeyAgreement.PublicKey

extension SymmetricKey {
    static let derived: SymmetricKey = """
        6f 26 15 a1 08 c7 02 c5 67 8f 54 fc 9d ba b6 97
        16 c0 76 18 9c 48 25 0c eb ea c3 57 6c 36 11 ba
        """
}

test.case("tls 1.3 derived") {
    let derived = Keys<SHA256>.derivedForHandshakeSecret
    expect(derived == .derived)
}

extension SymmetricKey {
    static let handshakeSecret: SymmetricKey = """
        1d c8 26 e9 36 06 aa 6f dc 0a ad c1 2f 74 1b 01
        04 6a a6 b9 9f 69 1e d2 21 a9 f0 ca 04 3f be ac
        """
}

test.case("tls handshake secret") {
    let sharedSecret = try Client.privateKey
        .sharedSecretFromKeyAgreement(with: Server.publicKey)

    let sharedSecret2 = try Server.privateKey
        .sharedSecretFromKeyAgreement(with: Client.publicKey)

    expect(sharedSecret == sharedSecret2)

    let handshakeSecret = Keys<SHA256>.handshakeSecret(
        sharedSecret: .init(data: sharedSecret))

    expect(handshakeSecret == .handshakeSecret)
}

extension SymmetricKey {
    static let serverHandshakeTrafficSecret: SymmetricKey = """
        b6 7b 7d 69 0c c1 6c 4e 75 e5 42 13 cb 2d 37 b4
        e9 c9 12 bc de d9 10 5d 42 be fd 59 d3 91 ad 38
        """

    static let clientHandshakeTrafficSecret: SymmetricKey = """
        b3 ed db 12 6e 06 7f 35 a7 80 b3 ab f4 5e 2d 8f
        3b 1a 95 07 38 f5 2e 96 00 74 6a 0e 27 a5 5a 21
        """

    static let derivedForMasterSecret: SymmetricKey = """
        43 de 77 e0 c7 77 13 85 9a 94 4d b9 db 25 90 b5
        31 90 a6 5b 3e e2 e4 f1 2d d7 a0 bb 7c e2 54 b4
        """

    static let masterSecret: SymmetricKey = """
        18 df 06 84 3d 13 a0 8b f2 a4 49 84 4c 5f 8a 47
        80 01 bc 4d 4c 62 79 84 d5 a4 1d a8 d0 40 29 19
        """
}

test.case("derive handshake traffic secrets") {
    var hash = SHA256()
    hash.update(data: Client.hello)
    hash.update(data: Server.hello)
    let digest = hash.finalize()

    let serverHandshakeTrafficSecret = Keys<SHA256>.serverHSTrafficSecret(
        handshakeSecret: .handshakeSecret,
        transcriptHash: digest)

    expect(serverHandshakeTrafficSecret == .serverHandshakeTrafficSecret)

    let clientHandshakeTrafficSecret = Keys<SHA256>.clientHSTrafficSecret(
        handshakeSecret: .handshakeSecret,
        transcriptHash: digest)

    expect(clientHandshakeTrafficSecret == .clientHandshakeTrafficSecret)
}

test.case("derive master secret") {
    let derivedForMasterSecret = Keys<SHA256>.derivedForMasterSecret(
        handshakeSecret: .handshakeSecret)

    expect(derivedForMasterSecret == .derivedForMasterSecret)

    let masterSecret = Keys<SHA256>.masterSecret(
        handshakeSecret: .handshakeSecret)

    expect(masterSecret == .masterSecret)
}

extension SymmetricKey {
    static let hsServerKey: SymmetricKey =
        "3f ce 51 60 09 c2 17 27 d0 f2 e4 e8 6e e4 03 bc"

    static let hsServerBaseIV: SymmetricKey =
        "5d 31 3e b2 67 12 76 ee 13 00 0b 30"
}

extension PerRecordNonce {
    static let hsServerPRN: PerRecordNonce = .init(
        baseIV: SymmetricKey.hsServerBaseIV.bytes)
}

test.case("derive server write keys") {
    let writeKeys = Keys<SHA256>.peerTrafficKeys(
        secret: .serverHandshakeTrafficSecret)

    expect(writeKeys.key == .hsServerKey)
    expect(writeKeys.iv == .hsServerPRN)
}

extension SymmetricKey {
    static let hsClientKey: SymmetricKey =
        "db fa a6 93 d1 76 2c 5b 66 6a f5 d9 50 25 8d 01"

    static let hsClientBaseIV: SymmetricKey =
        "5b d3 c7 1b 83 6e 0b 76 bb 73 26 5f"
}

extension PerRecordNonce {
    static let hsClientPRN: PerRecordNonce = .init(
        baseIV: SymmetricKey.hsClientBaseIV.bytes)
}

test.case("derive client write keys") {
    let writeKeys = Keys<SHA256>.peerTrafficKeys(
        secret: .clientHandshakeTrafficSecret)

    expect(writeKeys.key == .hsClientKey)
    expect(writeKeys.iv == .hsClientPRN)
}

test.run()

// MARK: Static data

extension Client {
    static let privateKey: PrivateKey = """
        49 af 42 ba 7f 79 94 85 2d 71 3e f2 78 4b cb ca
        a7 91 1d e2 6a dc 56 42 cb 63 45 40 e7 ea 50 05
        """

    static let publicKey: PublicKey = """
        99 38 1d e5 60 e4 bd 43 d2 3d 8e 43 5a 7d ba fe
        b3 c0 6e 51 c1 3c ae 4d 54 13 69 1e 52 9a af 2c
        """
}

extension Server {
    static let privateKey: PrivateKey = """
        b1 58 0e ea df 6d d5 89 b8 ef 4f 2d 56 52 57 8c
        c8 10 e9 98 01 91 ec 8d 05 83 08 ce a2 16 a2 1e
        """

    static let publicKey: PublicKey = """
        c9 82 88 76 11 20 95 fe 66 76 2b db f7 c6 72 e1
        56 d6 cc 25 3b 83 3d f1 dd 69 b1 b0 4e 75 1f 0f
        """
}

extension Client {
    static let hello: [UInt8] = parse("""
        01 00 00 c0 03 03 cb 34 ec b1 e7 81 63 ba 1c 38
        c6 da cb 19 6a 6d ff a2 1a 8d 99 12 ec 18 a2 ef
        62 83 02 4d ec e7 00 00 06 13 01 13 03 13 02 01
        00 00 91 00 00 00 0b 00 09 00 00 06 73 65 72 76
        65 72 ff 01 00 01 00 00 0a 00 14 00 12 00 1d 00
        17 00 18 00 19 01 00 01 01 01 02 01 03 01 04 00
        23 00 00 00 33 00 26 00 24 00 1d 00 20 99 38 1d
        e5 60 e4 bd 43 d2 3d 8e 43 5a 7d ba fe b3 c0 6e
        51 c1 3c ae 4d 54 13 69 1e 52 9a af 2c 00 2b 00
        03 02 03 04 00 0d 00 20 00 1e 04 03 05 03 06 03
        02 03 08 04 08 05 08 06 04 01 05 01 06 01 02 01
        04 02 05 02 06 02 02 02 00 2d 00 02 01 01 00 1c
        00 02 40 01
        """)
}

extension Server {
    static let hello: [UInt8] = parse("""
        02 00 00 56 03 03 a6 af 06 a4 12 18 60 dc 5e 6e
        60 24 9c d3 4c 95 93 0c 8a c5 cb 14 34 da c1 55
        77 2e d3 e2 69 28 00 13 01 00 00 2e 00 33 00 24
        00 1d 00 20 c9 82 88 76 11 20 95 fe 66 76 2b db
        f7 c6 72 e1 56 d6 cc 25 3b 83 3d f1 dd 69 b1 b0
        4e 75 1f 0f 00 2b 00 02 03 04
        """)
}
