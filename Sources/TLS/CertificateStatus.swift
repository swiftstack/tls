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

extension CertificateStatus {
    init(from stream: StreamReader) throws {
        guard let type = try RawType(from: stream) else {
            throw TLSError.invalidExtension
        }
        self = try stream.withSubStream(sizedBy: UInt24.self) { stream in
            switch type {
            case .ocsp: return .ocsp(try .init(from: stream))
            }
        }
    }

    func encode(to stream: StreamWriter) throws {
        switch self {
        case .ocsp(let response):
            try RawType.ocsp.encode(to: stream)
            try stream.withSubStream(sizedBy: UInt24.self) { stream in
                try response.encode(to: stream)
            }
        }
    }
}

extension OCSP.Response {
    init(from stream: StreamReader) throws {
        let asn1 = try ASN1(from: stream)
        try self.init(from: asn1)
    }

    func encode(to stream: StreamWriter) throws {
        let asn1 = self.encode()
        try asn1.encode(to: stream)
    }
}
