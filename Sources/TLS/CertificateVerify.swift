import Stream

public struct CertificateVerify: Equatable {
    public let algorithm: Extension.SignatureAlgorithm
    public let signature: [UInt8]
}

extension CertificateVerify: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let algorithm = try await Extension.SignatureAlgorithm
            .decode(from: stream)
        let length = try await stream.read(UInt16.self)
        let bytes = try await stream.read(count: Int(length))
        return .init(algorithm: algorithm, signature: bytes)
    }

    func encode(to stream: StreamWriter) async throws {
        try await algorithm.encode(to: stream)
        try await stream.write(UInt16(signature.count))
        try await stream.write(signature)
    }
}
