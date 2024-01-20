import Stream
import Crypto

// https://tools.ietf.org/html/rfc6961

public enum CertificateStatus: Equatable {
    case ocsp(OCSP.Response)

    // https://tools.ietf.org/html/rfc6961#section-3

    enum RawType: UInt8 {
        case ocsp = 0x01
    }
}

extension CertificateStatus: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        guard let type = try await RawType.decode(from: stream) else {
            throw TLSError.invalidExtension
        }
        return try await stream.withSubStreamReader(
            sizedBy: UInt24.self
        ) { sub in
            switch type {
            case .ocsp: return .ocsp(try await .decode(from: sub))
            }
        }
    }

    func encode(to stream: StreamWriter) async throws {
        switch self {
        case .ocsp(let response):
            try await RawType.ocsp.encode(to: stream)
            try await stream.withSubStreamWriter(sizedBy: UInt24.self) { sub in
                try await response.encode(to: sub)
            }
        }
    }
}

extension OCSP.Response {
    static func decode(from stream: StreamReader) async throws -> Self {
        let asn1 = try await ASN1.decode(from: stream)
        return try await .decode(from: asn1)
    }

    func encode(to stream: StreamWriter) async throws {
        let asn1 = self.encode()
        try await asn1.encode(to: stream)
    }
}
