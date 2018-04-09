import Stream

public struct RecordLayer: Equatable {
    public let version: Version
    public let content: Content

    public init(version: Version, content: Content) {
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

extension RecordLayer.ContentType {
    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = RecordLayer.ContentType(rawValue: rawType) else {
            throw TLSError.invalidRecordContentType
        }
        self = type
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(self.rawValue)
    }
}

extension RecordLayer {
    public init(from stream: StreamReader) throws {
        let type = try ContentType(from: stream)

        self.version = try Version(from: stream)
        self.content = try stream.withSubStream(sizedBy: UInt16.self)
        { stream in
            switch type {
            case .changeChiperSpec:
                return .changeChiperSpec(try ChangeCiperSpec(from: stream))
            case .alert:
                return .alert(try Alert(from: stream))
            case .handshake:
                return .handshake(try Handshake(from: stream))
            case .applicationData:
                return .applicationData(try stream.readUntilEnd())
            case .heartbeat:
                return .heartbeat
            }
        }
    }

    public func encode(to stream: StreamWriter) throws {
        func write(_ type: ContentType) throws {
            try stream.write(type.rawValue)
        }
        switch content {
        case .changeChiperSpec: try write(.changeChiperSpec)
        case .alert: try write(.alert)
        case .handshake: try write(.handshake)
        case .applicationData: try write(.applicationData)
        case .heartbeat: try write(.heartbeat)
        }

        try version.encode(to: stream)

        try stream.withSubStream(sizedBy: UInt16.self) { stream in
            switch content {
            case .changeChiperSpec(let value): try value.encode(to: stream)
            case .alert(let value): try value.encode(to: stream)
            case .handshake(let value): try value.encode(to: stream)
            case .applicationData(let value): try stream.write(value)
            case .heartbeat: break
            }
        }
    }
}
