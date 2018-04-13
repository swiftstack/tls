import Stream
import Crypto

extension Certificate {
    public enum Status: Equatable {
        case ocsp(OCSPResponse)

        public enum RawType: UInt8 {
            case ocsp = 0x01
        }

        // https://tools.ietf.org/html/rfc2560#section-4.2.1

        public struct OCSPResponse: Equatable {
            enum Status: UInt8 {
                case success = 0x00 // Response has valid confirmations
                case malformedRequest = 0x01 // Illegal confirmation request
                case internalError = 0x02 // Internal error in issuer
                case tryLater = 0x03 // Try again later
                case sigRequired = 0x05 // Must sign the request
                case unauthorized = 0x06 // Request unauthorized
            }

            let status: Status
            let basicResponse: BasicOCSPResponse
        }

        public struct BasicOCSPResponse: Equatable {
            let value: ASN1
        }
    }
}

extension Certificate.Status.RawType {
    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = Certificate.Status.RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        self = type
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}

extension Certificate.Status {
    init(from stream: StreamReader) throws {
        let type = try Certificate.Status.RawType(from: stream)
        self = try stream.withSubStream(sizedBy: UInt24.self) { stream in
            switch type {
            case .ocsp: return .ocsp(try OCSPResponse(from: stream))
            }
        }
    }

    func encode(to stream: StreamWriter) throws {
        switch self {
        case .ocsp(let response):
            try Certificate.Status.RawType.ocsp.encode(to: stream)
            try stream.withSubStream(sizedBy: UInt24.self) { stream in
                try response.encode(to: stream)
            }
        }
    }
}

extension Certificate.Status.OCSPResponse.Status {
    typealias Status = Certificate.Status.OCSPResponse.Status

    init(from asn1: ASN1) throws {
        guard asn1.identifier.isConstructed == false,
            asn1.identifier.class == .universal,
            asn1.identifier.tag == .enumerated,
            case .integer(let value) = asn1.content,
            let rawStatus = UInt8(exactly: value),
            let status = Status(rawValue: rawStatus)
        else {
            throw TLSError.invalidCertificateStatus
        }
        self = status
    }

    var asn1: ASN1 {
        return ASN1(
            identifier: .init(
                isConstructed: true,
                class: .universal,
                tag: .enumerated),
            content: .integer(Int(rawValue)))
    }
}

// TODO: Decode / Encode
extension Certificate.Status.BasicOCSPResponse {
    init(from asn1: ASN1) throws {
        self.value = asn1
    }

    var asn1: ASN1 {
        return self.value
    }
}

struct ASN1Objects {
    static let basicOCSP: [UInt8] = [
        0x2b, 0x06, 0x01, 0x05, 0x05, 0x07, 0x30, 0x01, 0x01
    ]
}

extension Certificate.Status.OCSPResponse {
    typealias BasicOCSPResponse = Certificate.Status.BasicOCSPResponse

    init(from stream: StreamReader) throws {
        let asn1 = try ASN1(from: stream)

        guard asn1.identifier.isConstructed,
            asn1.identifier.class == .universal,
            asn1.identifier.tag == .sequence,
            case .sequence(let sequence) = asn1.content,
            sequence.count >= 2
        else {
            throw TLSError.invalidCertificateStatus
        }
        let status = try Status(from: sequence[0])
        guard status == .success else {
            throw TLSError.invalidCertificateStatus
        }

        self.status  = status

        let eoc = sequence[1]
        guard
            eoc.identifier.isConstructed,
            eoc.identifier.class == .contextSpecific,
            eoc.identifier.tag == .endOfContent,
            case .sequence(let container) = eoc.content,
            container.count == 1
        else {
            throw TLSError.invalidCertificateStatus
        }

        let typeData = container[0]
        guard
            typeData.identifier.isConstructed,
            typeData.identifier.class == .universal,
            typeData.identifier.tag == .sequence,
            case .sequence(let typeDataSequence) = typeData.content,
            typeDataSequence.count == 2
        else {
            throw TLSError.invalidCertificateStatus
        }

        let type = typeDataSequence[0]
        let data = typeDataSequence[1]

        guard type.identifier.isConstructed == false,
            type.identifier.class == .universal,
            type.identifier.tag == .objectIdentifier,
            case .data(let object) = type.content,
            object == ASN1Objects.basicOCSP
        else {
            throw TLSError.invalidCertificateStatus
        }

        guard data.identifier.isConstructed == false,
            data.identifier.class == .universal,
            data.identifier.tag == .octetString,
            case .data(let basicOCSPBytes) = data.content
        else {
            throw TLSError.invalidCertificateStatus
        }

        let basicOCSP = try ASN1(from: InputByteStream(basicOCSPBytes))

        self.basicResponse = try BasicOCSPResponse(from: basicOCSP)
    }

    func encode(to stream: StreamWriter) throws {
        let asn1 = ASN1(
            identifier: .init(
                isConstructed: true,
                class: .universal,
                tag: .sequence),
            content: .sequence([
                status.asn1,
                basicResponse.asn1
            ]))

        try asn1.encode(to: stream)
    }
}
