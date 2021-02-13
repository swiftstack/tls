import Stream
import Platform

// https://tools.ietf.org/html/rfc4366#section-3.6

extension Extension {
    public enum StatusRequest: Equatable {
        case none
        case ocsp(OCSPStatusRequest)

        enum RawType: UInt8 {
            case ocsp = 0x01
        }
    }

    public struct OCSPStatusRequest: Equatable {
        public let responderIdList: [UInt8]
        public let extensions: [UInt8]

        public init (responderIdList: [UInt8] = [], extensions: [UInt8] = []) {
            self.responderIdList = responderIdList
            self.extensions = extensions
        }
    }
}

extension Extension.OCSPStatusRequest {
    static func decode(from stream: StreamReader) async throws -> Self {
        let responderIdList: [UInt8]
        let respondersLength = Int(try await stream.read(UInt16.self))
        switch respondersLength {
        case 0: responderIdList = []
        default: responderIdList = try await stream.read(count: respondersLength)
        }

        let extensions: [UInt8]
        let extensionsLength = Int(try await stream.read(UInt16.self))
        switch extensionsLength {
        case 0: extensions = []
        default: extensions = try await stream.read(count: extensionsLength)
        }
        return .init(responderIdList: responderIdList, extensions: extensions)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(UInt16(responderIdList.count))
        if responderIdList.count > 0 {
            try await stream.write(responderIdList)
        }
        try await stream.write(UInt16(extensions.count))
        if extensions.count > 0 {
            try await stream.write(extensions)
        }
    }
}

extension Extension.StatusRequest {
    static func decode(from stream: StreamReader) async throws -> Self {
        guard let type = try await RawType.decode(from: stream) else {
            throw TLSError.invalidExtension
        }
        switch type {
        case .ocsp: return .ocsp(try await .decode(from: stream))
        }
    }

    func encode(to stream: StreamWriter) async throws {
        switch self {
        case .none:
            return
        case .ocsp(let request):
            try await RawType.ocsp.encode(to: stream)
            try await request.encode(to: stream)
        }
    }
}
