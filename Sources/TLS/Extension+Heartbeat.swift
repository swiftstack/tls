import Stream

extension Extension {
    public struct Heartbeat: Equatable {
        public enum Mode: UInt8 {
            case allowed = 1
        }
        public let mode: Mode

        public init(mode: Mode) {
            self.mode = mode
        }
    }
}

extension Extension.Heartbeat {
    init(from stream: StreamReader) throws {
        let rawMode = try stream.read(UInt8.self)
        guard let mode = Mode(rawValue: rawMode) else {
            throw TLSError.invalidExtension
        }
        self.mode = mode
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(mode.rawValue)
    }
}
