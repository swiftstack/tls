import Hex
import Stream
import CryptoKit

class ClientSession<T: Stream> {
    struct Configuration {
        typealias SupportedGroups = ClientHello.SupportedGroups
        typealias SignatureAlgorithms = ClientHello.SignatureAlgorithms
        typealias SupportedVersions = ClientHello.SupportedVersions

        let ciperSuites: CiperSuites
        let supportedGroups: SupportedGroups
        let signatureAlgorithms: SignatureAlgorithms

        init(
            ciperSuites: CiperSuites = [.tls_aes_128_gcm_sha256],
            supportedGroups: SupportedGroups = [.x25519],
            signatureAlgorithms: SignatureAlgorithms = [.rsa_pss_rsae_sha256]
        ) {
            self.ciperSuites = ciperSuites
            self.supportedGroups = supportedGroups
            self.signatureAlgorithms = signatureAlgorithms
        }

        static var `default`: Configuration { .init() }
    }

    let privateKey: PrivateKey

    var derivedKeys: HandshakeDerivedKeys? = nil
    var trafficKeys: TrafficKeys? = nil

    let configuration: Configuration
    let stream: BufferedStream<T>

    init(
        privateKey: PrivateKey = .init(),
        configuration: Configuration = .default,
        stream: T
    ) {
        self.privateKey = privateKey
        self.configuration = configuration
        self.stream = BufferedStream(baseStream: stream, capacity: 16640)
    }

    func deriveApplicationKeys(using keys: HandshakeDerivedKeys) {
        self.derivedKeys = keys
        self.trafficKeys = Keys<SHA256>.applicationTrafficKeys(
            trafficSecrets: keys.trafficSecrets)
    }

    public func handshake(with hostname: String) async throws -> some Stream {
        let session = HandshakeSession(
            privateKey: privateKey,
            configuration: configuration,
            stream: stream)
        let derivedKeys = try await session.perform(hostname: hostname)
        deriveApplicationKeys(using: derivedKeys)
        return self
    }

    // @testable
    func handshake(_ helloBytes: [UInt8]) async throws {
        let session = HandshakeSession(
            privateKey: privateKey,
            configuration: configuration,
            stream: stream)
        let derivedKeys = try await session.perform(helloBytes: helloBytes)
        deriveApplicationKeys(using: derivedKeys)
    }

    func handle(contentType: Record.ContentType, payload: [UInt8]) async throws {
        switch contentType {
        case .handshake:
            let stream = InputByteStream(payload)
            let handshake = try await Handshake.decode(from: stream)
            print("handshake data:", handshake)
        case .alert:
            let stream = InputByteStream(payload)
            let alert = try await Alert.decode(from: stream)
            print("alert message:", alert)
        default:
            print("unexpected record type", payload)
        }
    }

    func send(_ bytes: UnsafeRawBufferPointer) async throws {
        guard let keys = trafficKeys else {
            fatalError("invalid traffic keys")
        }
        try await send(
            contentType: .applicationData,
            payload: bytes,
            keys: keys.write)
    }

    func receive() async throws -> [UInt8] {
        guard let keys = trafficKeys else {
            fatalError("invalid traffic keys")
        }
        return try await receive(keys: keys.read)
    }

    private func send(
        contentType: Record.ContentType,
        payload: UnsafeRawBufferPointer,
        keys: PeerTrafficKeys
    ) async throws {
        let authTagSize = 16

        let payload = [UInt8](payload) + [contentType.rawValue]

        let header = Record.Header.init(
            type: .applicationData,
            payloadLength: payload.count + authTagSize)

        let headerBytes = try await header.encode()

        let encryptedPayload = try encrypt(
            payload,
            using: keys,
            authenticating: headerBytes)

        try await send(header: header, payload: encryptedPayload)
    }

    private func send(header: Record.Header, payload: [UInt8]) async throws {
        try await header.encode(to: stream)
        try await stream.write(payload)
        try await stream.flush()
    }

    private func receive(keys: PeerTrafficKeys) async throws -> [UInt8] {
        while try await stream.cache(count: 5) {
            let ad = try await stream.peek(count: 5, as: [UInt8].self)
            let header = try await Record.Header.decode(from: stream)

            guard let recordType = header.type else {
                throw TLSError.invalidRecordContentType
            }
            guard recordType == .applicationData else {
                throw TLSError.unexpectedRecordContentType
            }

            let data = try await stream.read(count: header.length) { buffer in
                try decrypt(buffer, using: keys, authenticating: ad)
            }

            guard let rawContentType = data.last,
                  let contentType = Record.ContentType(rawValue: rawContentType)
            else {
                throw TLSError.invalidRecordContentType
            }

            let payload = [UInt8](data.dropLast())

            guard contentType == .applicationData else {
                try await handle(contentType: contentType, payload: payload)
                continue
            }

            return payload
        }

        return []
    }
}
