import Stream

extension RawRepresentable where RawValue == UInt8 {
    @inline(__always)
    init?(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        self.init(rawValue: rawType)
    }

    @inline(__always)
    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}
