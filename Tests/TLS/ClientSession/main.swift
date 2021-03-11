import Hex
import Test
import Stream
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

class TestStream: Stream {
    let inputStream: InputByteStream
    let outputStream: OutputByteStream

    init(serverData: [UInt8]) {
        self.inputStream = .init(serverData)
        self.outputStream = .init()
    }

    func read(to pointer: UnsafeMutableRawPointer, byteCount: Int) async throws -> Int {
        try inputStream.read(to: pointer, byteCount: byteCount)
    }

    func write(from buffer: UnsafeRawPointer, byteCount: Int) async throws -> Int {
        outputStream.write(from: buffer, byteCount: byteCount)
    }
}

test.case("handshake example") {
    let stream = TestStream(serverData: Server.combined)
    let session = ClientSession(privateKey: Client.privateKey, stream: stream)
    try await session.handshake(Client.hello)

    let finishedSize = Client.finishedRecord.count
    let finishedBytes = [UInt8](stream.outputStream.bytes.suffix(finishedSize))
    expect(finishedBytes == Client.finishedRecord)
}

test.run()

// MARK: Static data

extension Client {
    static let privateKey: PrivateKey = """
        20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f
        30 31 32 33 34 35 36 37 38 39 3a 3b 3c 3d 3e 3f
        """

    static let hello: [UInt8] = parse("""
        01 00 00 c6 03 03 00 01 02 03 04 05 06 07 08 09
        0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19
        1a 1b 1c 1d 1e 1f 20 e0 e1 e2 e3 e4 e5 e6 e7 e8
        e9 ea eb ec ed ee ef f0 f1 f2 f3 f4 f5 f6 f7 f8
        f9 fa fb fc fd fe ff 00 06 13 01 13 02 13 03 01
        00 00 77 00 00 00 18 00 16 00 00 13 65 78 61 6d
        70 6c 65 2e 75 6c 66 68 65 69 6d 2e 6e 65 74 00
        0a 00 08 00 06 00 1d 00 17 00 18 00 0d 00 14 00
        12 04 03 08 04 04 01 05 03 08 05 05 01 08 06 06
        01 02 01 00 33 00 26 00 24 00 1d 00 20 35 80 72
        d6 36 58 80 d1 ae ea 32 9a df 91 21 38 38 51 ed
        21 a2 8e 3b 75 e9 65 d0 d2 cd 16 62 54 00 2d 00
        02 01 01 00 2b 00 03 02 03 04
        """)

    static let finishedHMAC: [UInt8] = parse("""
        14 00 00 20 97 60 17 a7 7a e4 7f 16 58 e2 8f 70
        85 fe 37 d1 49 d1 e9 c9 1f 56 e1 ae bb e0 c6 bb
        05 4b d9 2b 16
        """)

    static let finishedRecord: [UInt8] = parse("""
        17 03 03 00 35 71 55 df f4 74 1b df c0 c4 3a 1d
        e0 b0 11 33 ac 19 74 ed c8 8e 70 91 c3 ff 1e 26
        60 cd 71 92 83 ba 40 f7 c1 0b 54 35 d4 eb 22 d0
        53 6c 80 c9 32 e2 f3 c9 60 83
        """)
}

extension Server {
    static let privateKey: PrivateKey = """
        90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f
        a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
        """

    static var combined: [UInt8] {
        hello + handshake + newSessionTickets
    }

    static let hello: [UInt8] = parse("""
        16 03 03 00 7a 02 00 00 76 03 03 70 71 72 73 74
        75 76 77 78 79 7a 7b 7c 7d 7e 7f 80 81 82 83 84
        85 86 87 88 89 8a 8b 8c 8d 8e 8f 20 e0 e1 e2 e3
        e4 e5 e6 e7 e8 e9 ea eb ec ed ee ef f0 f1 f2 f3
        f4 f5 f6 f7 f8 f9 fa fb fc fd fe ff 13 01 00 00
        2e 00 33 00 24 00 1d 00 20 9f d7 ad 6d cf f4 29
        8d d3 f9 6d 5b 1b 2a f9 10 a0 53 5b 14 88 d7 f8
        fa bb 34 9a 98 28 80 b6 15 00 2b 00 02 03 04
        """)

    static let handshake: [UInt8] = parse("""
        17 03 03 04 75 da 1e c2 d7 bd a8 eb f7 3e dd 50
        10 fb a8 08 9f d4 26 b0 ea 1e a4 d8 8d 07 4f fe
        a8 a9 87 3a f5 f5 02 26 1e 34 b1 56 33 43 e9 be
        b6 13 2e 7e 83 6d 65 db 6d cf 00 bc 40 19 35 ae
        36 9c 44 0d 67 af 71 9e c0 3b 98 4c 45 21 b9 05
        d5 8b a2 19 7c 45 c4 f7 73 bd 9d d1 21 b4 d2 d4
        e6 ad ff fa 27 c2 a8 1a 99 a8 ef e8 56 c3 5e e0
        8b 71 b3 e4 41 bb ec aa 65 fe 72 08 15 ca b5 8d
        b3 ef a8 d1 e5 b7 1c 58 e8 d1 fd b6 b2 1b fc 66
        a9 86 5f 85 2c 1b 4b 64 0e 94 bd 90 84 69 e7 15
        1f 9b bc a3 ce 53 22 4a 27 06 2c eb 24 0a 10 5b
        d3 13 2d c1 85 44 47 77 94 c3 73 bc 0f b5 a2 67
        88 5c 85 7d 4c cb 4d 31 74 2b 7a 29 62 40 29 fd
        05 94 0d e3 f9 f9 b6 e0 a9 a2 37 67 2b c6 24 ba
        28 93 a2 17 09 83 3c 52 76 d4 13 63 1b dd e6 ae
        70 08 c6 97 a8 ef 42 8a 79 db f6 e8 bb eb 47 c4
        e4 08 ef 65 6d 9d c1 9b 8b 5d 49 bc 09 1e 21 77
        35 75 94 c8 ac d4 1c 10 1c 77 50 cb 11 b5 be 6a
        19 4b 8f 87 70 88 c9 82 8e 35 07 da da 17 bb 14
        bb 2c 73 89 03 c7 aa b4 0c 54 5c 46 aa 53 82 3b
        12 01 81 a1 6c e9 28 76 28 8c 4a cd 81 5b 23 3d
        96 bb 57 2b 16 2e c1 b9 d7 12 f2 c3 96 6c aa c9
        cf 17 4f 3a ed fe c4 d1 9f f9 a8 7f 8e 21 e8 e1
        a9 78 9b 49 0b a0 5f 1d eb d2 17 32 fb 2e 15 a0
        17 c4 75 c4 fd 00 be 04 21 86 dc 29 e6 8b b7 ec
        e1 92 43 8f 3b 0c 5e f8 e4 a5 35 83 a0 19 43 cf
        84 bb a5 84 21 73 a6 b3 a7 28 95 66 68 7c 30 18
        f7 64 ab 18 10 31 69 91 93 28 71 3c 3b d4 63 d3
        39 8a 1f eb 8e 68 e4 4c fe 48 2f 72 84 7f 46 c8
        0e 6c c7 f6 cc f1 79 f4 82 c8 88 59 4e 76 27 66
        53 b4 83 98 a2 6c 7c 9e 42 0c b6 c1 d3 bc 76 46
        f3 3b b8 32 bf ba 98 48 9c ad fb d5 5d d8 b2 c5
        76 87 a4 7a cb a4 ab 39 01 52 d8 fb b3 f2 03 27
        d8 24 b2 84 d2 88 fb 01 52 e4 9f c4 46 78 ae d4
        d3 f0 85 b7 c5 5d e7 7b d4 5a f8 12 fc 37 94 4a
        d2 45 4f 99 fb b3 4a 58 3b f1 6b 67 65 9e 6f 21
        6d 34 b1 d7 9b 1b 4d ec c0 98 a4 42 07 e1 c5 fe
        eb 6c e3 0a cc 2c f7 e2 b1 34 49 0b 44 27 44 77
        2d 18 4e 59 03 8a a5 17 a9 71 54 18 1e 4d fd 94
        fe 72 a5 a4 ca 2e 7e 22 bc e7 33 d0 3e 7d 93 19
        71 0b ef bc 30 d7 82 6b 72 85 19 ba 74 69 0e 4f
        90 65 87 a0 38 28 95 b9 0d 82 ed 3e 35 7f af 8e
        59 ac a8 5f d2 06 3a b5 92 d8 3d 24 5a 91 9e a5
        3c 50 1b 9a cc d2 a1 ed 95 1f 43 c0 49 ab 9d 25
        c7 f1 b7 0a e4 f9 42 ed b1 f3 11 f7 41 78 33 06
        22 45 b4 29 d4 f0 13 ae 90 19 ff 52 04 4c 97 c7
        3b 88 82 cf 03 95 5c 73 9f 87 4a 02 96 37 c0 f0
        60 71 00 e3 07 0f 40 8d 08 2a a7 a2 ab f1 3e 73
        bd 1e 25 2c 22 8a ba 7a 9c 1f 07 5b c4 39 57 1b
        35 93 2f 5c 91 2c b0 b3 8d a1 c9 5e 64 fc f9 bf
        ec 0b 9b 0d d8 f0 42 fd f0 5e 50 58 29 9e 96 e4
        18 50 74 91 9d 90 b7 b3 b0 a9 7e 22 42 ca 08 cd
        99 c9 ec b1 2f c4 9a db 2b 25 72 40 cc 38 78 02
        f0 0e 0e 49 95 26 63 ea 27 84 08 70 9b ce 5b 36
        3c 03 60 93 d7 a0 5d 44 0c 9e 7a 7a bb 3d 71 eb
        b4 d1 0b fc 77 81 bc d6 6f 79 32 2c 18 26 2d fc
        2d cc f3 e5 f1 ea 98 be a3 ca ae 8a 83 70 63 12
        76 44 23 a6 92 ae 0c 1e 2e 23 b0 16 86 5f fb 12
        5b 22 38 57 54 7a c7 e2 46 84 33 b5 26 98 43 ab
        ba bb e9 f6 f4 38 d7 e3 87 e3 61 7a 21 9f 62 54
        0e 73 43 e1 bb f4 93 55 fb 5a 19 38 04 84 39 cb
        a5 ce e8 19 19 9b 2b 5c 39 fd 35 1a a2 74 53 6a
        ad b6 82 b5 78 94 3f 0c cf 48 e4 ec 7d dc 93 8e
        2f d0 1a cf aa 1e 72 17 f7 b3 89 28 5c 0d fd 31
        a1 54 5e d3 a8 5f ac 8e b9 da b6 ee 82 6a f9 0f
        9e 1e e5 d5 55 dd 1c 05 ae c0 77 f7 c8 03 cb c2
        f1 cf 98 39 3f 0f 37 83 8f fe a3 72 ff 70 88 86
        b0 59 34 e1 a6 45 12 de 14 46 08 86 4a 88 a5 c3
        a1 73 fd cf df 57 25 da 91 6e d5 07 e4 ca ec 87
        87 be fb 91 e3 ec 9b 22 2f a0 9f 37 4b d9 68 81
        ac 2d dd 1f 88 5d 42 ea 58 4c e0 8b 0e 45 5a 35
        0a e5 4d 76 34 9a a6 8c 71 ae
        """)

    static let newSessionTickets: [UInt8] = parse("""
        17 03 03 01 7d c4 d4 b7 1b 6f 4c 2f 30 13 02 74
        e7 b4 6e 40 89 68 de 07 98 f3 60 7c 43 60 bd 46
        de 37 a7 db 43 46 a1 35 b6 e5 db 37 c4 2f c8 e0
        9d da 3d d1 f1 a7 df 4d b2 c4 10 af dd a8 dd 81
        7b 8d 89 51 82 48 d2 d9 5e 5e 19 86 4c c5 5e 7f
        eb e7 0f 15 da f4 a6 4d 0b 30 75 08 79 cc b2 c5
        d2 88 be 35 74 5e 5d c6 01 d3 e5 74 f2 17 f1 b2
        a6 38 1a d7 b6 e1 b6 c7 18 b2 65 c6 f2 82 a1 92
        ac cb 22 5b 33 a7 73 3d 72 6e 92 ea 2b 4f 8b 00
        20 e7 c7 4b 73 96 30 7f 6f 5d 5a 2c 1c 61 69 c0
        f0 88 b6 bc 02 56 fa d5 bb 27 ee 82 f7 89 b1 65
        de 26 5b 4d 4d b8 40 86 ca 62 65 2b 1b 0c 22 b4
        e5 8f 98 bb b1 ec 0d 7c 91 bd 20 0c a0 8b f2 f7
        9f 86 f4 e5 60 55 8e 57 14 c5 25 23 83 92 e2 23
        2b 2c e2 24 17 fc 0d 4d 42 93 5f 54 9b 7b 27 a8
        6d f0 3e 53 04 4a 64 dd 74 bc ed c6 e4 29 12 e8
        ea 1b c9 35 20 d4 d4 6d 6e 1b f1 f4 39 35 94 18
        48 36 44 1a 3a f9 7c 4d 04 84 b5 c7 19 8f 68 19
        55 ea ae 55 19 26 ff 4e c8 39 fd d2 b8 48 10 ee
        ab 83 e0 75 c9 49 6b 45 43 15 fe da 35 b0 1e 46
        ee f4 1e f8 66 49 46 22 3f 1b ff b3 b9 ad 58 b5
        7f d8 ce 3f 7e e1 16 79 22 2e d3 6d 9e 07 03 18
        96 5f 82 1f 43 35 7a ae 5b 95 44 9a 00 5f 88 e0
        a2 da bf e0 c1 f6 88 62 76 43 a0 49 c3 49 2e af
        6f 0f
        """)
}
