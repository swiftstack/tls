import Stream

public struct Certificate: Equatable {

}

extension Array where Element == Certificate {
    init<T: StreamReader>(from stream: T) throws {
        let length = Int(try stream.read(UInt24.self).byteSwapped)
        self = try stream.withLimitedStream(by: length) { stream in
            var certificates = [Certificate]()
            while !stream.isEmpty {
                certificates.append(try Certificate(from: stream))
            }
            return certificates
        }
    }
}

extension Certificate {
    fileprivate static let headerSize = 3
    init<T: StreamReader>(from stream: T) throws {
        fatalError("not implemented")
        // let length = Int(buffer[0]) << 16 | Int(buffer[1]) << 8 | Int(buffer[2])
    }
}
