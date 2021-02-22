import Stream

extension Extension {
    public struct PostHandshakeAuth: Equatable {
        public init() {
            
        }
    }
}

extension Extension.PostHandshakeAuth {
    static func decode(from stream: StreamReader) async throws -> Self {
        return .init()
    }

    func encode(to stream: StreamWriter) async throws {

    }
}
