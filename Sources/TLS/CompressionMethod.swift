import Stream

public struct CompressionMethods: Equatable {
    var items: [CompressionMethod]

    init(_ items: [CompressionMethod]) {
        self.items = items
    }
}

public enum CompressionMethod: UInt8 {
    case none = 0
}

extension CompressionMethod: StreamCodable {
    init(from stream: StreamReader) throws {
        let rawMethod = try stream.read(UInt8.self)
        guard let method = CompressionMethod(rawValue: rawMethod) else {
            throw TLSError.invalidCompressionMethod
        }
        self = method
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}

extension CompressionMethods: StreamCodableCollection {
    typealias LengthType = UInt8
}

extension CompressionMethods: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CompressionMethod...) {
        self.init([CompressionMethod](elements))
    }
}
