import Stream
import CryptoKit

extension ClientSession {
    class HandshakeSession {
        let privateKey: PrivateKey
        let configuration: Configuration
        let stream: BufferedStream<T>

        var hash = SHA256()

        init(
            privateKey: PrivateKey = .init(),
            configuration: Configuration = .default,
            stream: BufferedStream<T>
        ) {
            self.privateKey = privateKey
            self.configuration = configuration
            self.stream = stream
        }

        func perform(hostname: String) async throws -> HandshakeDerivedKeys {
            let publicKey = privateKey.publicKey

            let hello: ClientHello = .init(
                version: .tls12,
                random: .init(),
                sessionId: .init(data: []),
                ciperSuites: configuration.ciperSuites,
                compressionMethods: [.none],
                extensions: [
                    .serverName([.init(type: .hostName, value: hostname)]),
                    .supportedGroups(configuration.supportedGroups),
                    .signatureAlgorithms(configuration.signatureAlgorithms),
                    .supportedVersions([.tls13]),
                    .pskKeyExchangeModes([.psk_dhe_ke]),
                    .keyShare([.init(group: .x25519, keyExchange: publicKey)])
                ])

            let helloBytes = try await Handshake.clientHello(hello).encode()
            return try await perform(helloBytes: helloBytes)
        }

        // FIXME: [Concurrency] crash
        // func perform(using hello: ClientHello) async throws -> HandshakeDerivedKeys {
        //    try await perform(helloBytes: Handshake.clientHello(hello).encode())
        // }

        func perform(helloBytes: [UInt8]) async throws -> HandshakeDerivedKeys {
            try await sendHello(helloBytes)

            let serverHello = try await receiveHello()
            guard let publicKey = serverHello.publicKey else {
                throw TLSError.invalidKeyExchange
            }
            let keys = try Keys<SHA256>.handshakeKeys(
                sharedSecret: privateKey.sharedSecret(with: publicKey),
                transcriptHash: hash.finalize())

            while try await stream.cache(count: 5) {
                let ad = try await stream.peek(count: 5, as: [UInt8].self)
                let header = try await Record.Header.decode(from: stream)

                guard let type = header.type else {
                    throw TLSError.invalidRecordContentType
                }
                guard type != .changeChiperSpec else {
                    try await stream.consume(count: header.length)
                    continue
                }
                guard type == .applicationData else {
                    throw TLSError.unexpectedRecordContentType
                }

                let data = try await stream.read(count: header.length) { buffer in
                    try decrypt(buffer, using: keys.traffic.read, authenticating: ad)
                }

                let dataStream = InputByteStream(data)
                while try dataStream.cache(count: 5) {
                    let handshake = try await Handshake.decode(from: dataStream)

                    if case .finished(let finished) = handshake {
                        // note: verify then update local hash
                        let hmac = hash.hmac(using: keys.finished.read)
                        try hmac.verify(with: finished.hmac)
                        // note: hash server finished before deriving keys
                        hash.update(data: try await handshake.encode())
                        let derivedKeys = deriveKeys(masterSecret: keys.master)
                        // note: hash changes here again
                        try await sendFinished(using: keys)
                        return derivedKeys
                    } else {
                        hash.update(data: try await handshake.encode())
                    }
                }
            }

            throw TLSError.handshakeFailed
        }

        func sendHello(_ bytes: [UInt8]) async throws {
            let header = Record.Header(
                type: .handshake,
                version: .tls10,
                payloadLength: bytes.count)

            try await header.encode(to: stream)
            try await stream.write(bytes)
            try await stream.flush()

            hash.update(data: bytes)
        }

        func receiveHello() async throws -> ServerHello {
            let header = try await Record.Header.decode(from: stream)
            guard header.type == .handshake else {
                throw TLSError.invalidServerHelloRecord
            }
            try await stream.peek(count: header.length) {
                hash.update(data: $0)
            }
            let handshake = try await Handshake.decode(from: stream)
            guard case let .serverHello(serverHello) = handshake else {
                throw TLSError.invalidServerHelloRecord
            }
            return serverHello
        }

        func deriveKeys(masterSecret: SymmetricKey) -> HandshakeDerivedKeys {
            let trafficSecrets = Keys<SHA256>.applicationTrafficSecrets(
                masterSecret: masterSecret,
                transcriptHash: hash.finalize())
            return .init(master: masterSecret, trafficSecrets: trafficSecrets)
        }

        func sendFinished(using keys: HandshakeKeys) async throws {
            let hmac = hash.hmac(using: keys.finished.write)
            let finished = Handshake.finished(.init(hmac: [UInt8](hmac)))
            let encoded = try await finished.encode()
            hash.update(data: encoded)

            try await send(
                contentType: .handshake,
                payload: encoded,
                keys: keys.traffic.write)
        }

        private func send(
            contentType: Record.ContentType,
            payload: [UInt8],
            keys: PeerTrafficKeys
        ) async throws {
            let authTagSize = 16

            var payload = payload
            payload.append(contentType.rawValue)

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
    }
}
