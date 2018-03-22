import Stream
import Platform

extension Extension {
    public struct StatusRequest: Equatable {
        public enum CertificateStatus: UInt8 {
            case ocsp = 0x01
        }

        public let certificateStatus: CertificateStatus?

        public init(certificateStatus: CertificateStatus?) {
            self.certificateStatus = certificateStatus
        }
    }
}

extension Extension.StatusRequest {
    init<T: StreamReader>(from stream: T) throws {
        let rawStatus = try stream.read(UInt8.self)
        let responderIdListlength = Int(try stream.read(UInt16.self).byteSwapped)
        let requestExtensionsLength = Int(try stream.read(UInt16.self).byteSwapped)

        guard let status = CertificateStatus(rawValue: rawStatus) else {
            throw TLSError.invalidExtension
        }

        guard responderIdListlength == 0 && requestExtensionsLength == 0 else {
            fatalError("not implemented")
        }

        self.certificateStatus = status
    }
}
