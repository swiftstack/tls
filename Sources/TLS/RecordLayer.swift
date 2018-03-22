import Stream

public struct RecordLayer: Equatable {
    public let version: ProtocolVersion
    public let content: Content

    public init(version: ProtocolVersion, content: Content) {
        self.version = version
        self.content = content
    }
}

extension RecordLayer {
    fileprivate enum ContentType: UInt8 {
        case changeChiperSpec = 20
        case alert = 21
        case handshake = 22
        case applicationData = 23
        case heartbeat = 24
    }

    public enum Content: Equatable {
        case changeChiperSpec(ChangeCiperSpec)
        case alert(Alert)
        case handshake(Handshake)
        case applicationData([UInt8])
        case heartbeat
    }
}

extension RecordLayer {
    public init<T: StreamReader>(from stream: T) throws {
        let type = try ContentType(from: stream)

        self.version = try ProtocolVersion(from: stream)

        let length = Int(try stream.read(UInt16.self).byteSwapped)
        self.content = try stream.withLimitedStream(by: length) { stream in
            switch type {
            case .changeChiperSpec:
                return .changeChiperSpec(try ChangeCiperSpec(from: stream))
            case .alert:
                return .alert(try Alert(from: stream))
            case .handshake:
                return .handshake(try Handshake(from: stream))
            case .applicationData:
                return .applicationData(try stream.read(count: length))
            case .heartbeat:
                return .heartbeat
            }
        }
    }
}

extension RecordLayer.ContentType {
    init<T: StreamReader>(from stream: T) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = RecordLayer.ContentType(rawValue: rawType) else {
            throw TLSError.invalidRecordContentType
        }
        self = type
    }
}
