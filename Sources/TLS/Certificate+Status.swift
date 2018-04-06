import Stream

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
                case tryLater = 0x03 //Try again later
                case sigRequired = 0x05 // Must sign the request
                case unauthorized = 0x06 // Request unauthorized
            }

            let unimplemented0: UInt8
            let unimplemented1: UInt8
            let unimplemented2: UInt8
            let unimplemented3: UInt8
            let unimplemented4: UInt8
            let unimplemented5: UInt8

            let status: Status

            let unimplemented6: UInt8
            let unimplemented7: UInt8
            let unimplemented8: UInt8
            let unimplemented9: UInt8

            let bytes: [UInt8]
        }
    }
}

extension Certificate.Status.RawType {
    init<T: StreamReader>(from stream: T) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = Certificate.Status.RawType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        self = type
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(rawValue)
    }
}

extension Certificate.Status {
    init<T: StreamReader>(from stream: T) throws {
        let type = try Certificate.Status.RawType(from: stream)
        let length = Int(try stream.read(UInt24.self).byteSwapped)
        self = try stream.withLimitedStream(by: length) { stream in
            switch type {
            case .ocsp: return .ocsp(try OCSPResponse(from: stream))
            }
        }
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        switch self {
        case .ocsp(let response):
            try Certificate.Status.RawType.ocsp.encode(to: stream)
            try stream.countingLength(as: UInt24.self) { stream in
                try response.encode(to: stream)
            }
        }
    }
}

extension Certificate.Status.OCSPResponse {
    init<T: StreamReader>(from stream: T) throws {
        self.unimplemented0 = try stream.read(UInt8.self)
        self.unimplemented1 = try stream.read(UInt8.self)
        self.unimplemented2 = try stream.read(UInt8.self)
        self.unimplemented3 = try stream.read(UInt8.self)
        self.unimplemented4 = try stream.read(UInt8.self)
        self.unimplemented5 = try stream.read(UInt8.self)

        let rawStatus = try stream.read(UInt8.self)
        guard let status = Status(rawValue: rawStatus) else {
            throw TLSError.invalidCertificateStatus
        }
        self.status = status

        self.unimplemented6 = try stream.read(UInt8.self)
        self.unimplemented7 = try stream.read(UInt8.self)
        self.unimplemented8 = try stream.read(UInt8.self)
        self.unimplemented9 = try stream.read(UInt8.self)

        self.bytes = try stream.readUntilEnd()
    }

    func encode<T: StreamWriter>(to stream: T) throws {
        try stream.write(unimplemented0)
        try stream.write(unimplemented1)
        try stream.write(unimplemented2)
        try stream.write(unimplemented3)
        try stream.write(unimplemented4)
        try stream.write(unimplemented5)

        try stream.write(status.rawValue)

        try stream.write(unimplemented6)
        try stream.write(unimplemented7)
        try stream.write(unimplemented8)
        try stream.write(unimplemented9)

        try stream.write(bytes)
    }
}
