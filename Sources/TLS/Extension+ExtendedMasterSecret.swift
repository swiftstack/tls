import Stream

extension Extension {
    public struct ExtendedMasterSecret: Equatable {
        public init() {
            
        }
    }
}

extension Extension.ExtendedMasterSecret {
    static func decode(from stream: StreamReader) async throws -> Self {
        return .init()
    }

    func encode(to stream: StreamWriter) async throws {

    }
}
