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
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawMode = try await stream.read(UInt8.self)
        guard let mode = Mode(rawValue: rawMode) else {
            throw TLSError.invalidExtension
        }
        return .init(mode: mode)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(mode.rawValue)
    }
}
