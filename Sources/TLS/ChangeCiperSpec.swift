import Stream

public enum ChangeCiperSpec: UInt8 {
    case `default` = 1
}

extension ChangeCiperSpec {
    static func decode(from stream: StreamReader) async throws -> Self {
        let rawSpec = try await stream.read(UInt8.self)
        guard let spec = ChangeCiperSpec(rawValue: rawSpec) else {
            throw TLSError.invalidChangeCiperSpec
        }
        return spec
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}
