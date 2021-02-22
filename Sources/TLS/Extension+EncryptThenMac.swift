import Stream

extension Extension {
    public struct EncryptThenMac: Equatable {
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
