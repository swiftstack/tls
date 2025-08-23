import Stream

extension Extension {
    public struct EncryptThenMac: Equatable, Sendable {
        public init() {

        }
    }
}

extension Extension.EncryptThenMac {
    static func decode(from stream: StreamReader) async throws -> Self {
        return .init()
    }

    func encode(to stream: StreamWriter) async throws {

    }
}
