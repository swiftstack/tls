import Crypto
import Stream

extension Array where Element == X509.Certificate {
    static func decode(from stream: StreamReader) async throws -> Self {
        return try await stream.withSubStreamReader(sizedBy: UInt24.self)
        { stream in
            var certificates = [X509.Certificate]()
            while !stream.isEmpty {
                let x509 = try await stream.withSubStreamReader(
                    sizedBy: UInt24.self
                ) { stream in
                    return try await X509.Certificate.decode(from: stream)
                }
                certificates.append(x509)
            }
            return certificates
        }
    }

    func encode(to stream: StreamWriter) async throws {
        guard count > 0 else {
            return
        }
        try await stream.withSubStreamWriter(sizedBy: UInt24.self) { stream in
            for value in self {
                try await stream.withSubStreamWriter(sizedBy: UInt24.self)
                { stream in
                    try await value.encode(to: stream)
                }
            }
        }
    }
}

extension X509.Certificate {
    static func decode(from stream: StreamReader) async throws -> Self {
        let asn1 = try await ASN1.decode(from: stream)
        return try await .decode(from: asn1)
    }

    func encode(to stream: StreamWriter) async throws {
        let asn1 = self.encode()
        try await asn1.encode(to: stream)
    }
}
