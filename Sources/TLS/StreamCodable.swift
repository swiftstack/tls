import Stream

protocol StreamDecodable {
    init(from stream: StreamReader) throws
}

protocol StreamEncodable {
    func encode(to stream: StreamWriter) throws
}

protocol StreamDecodableCollection {
    associatedtype LengthType: FixedWidthInteger
    associatedtype Element: StreamDecodable

    init(_ items: [Element])
}

protocol StreamEncodableCollection {
    associatedtype LengthType: FixedWidthInteger
    associatedtype Element: StreamEncodable

    var items: [Element] { get }
}

protocol StreamCodable: StreamEncodable, StreamDecodable {}
protocol StreamCodableCollection: StreamEncodableCollection, StreamDecodableCollection {}

extension StreamDecodableCollection {
    init(from stream: StreamReader) throws {
        let items = try stream.withSubStreamReader(sizedBy: LengthType.self)
        { stream -> [Element] in
            var items = [Element]()
            while !stream.isEmpty {
                items.append(try Element(from: stream))
            }
            return items
        }
        self.init(items)
    }
}

extension StreamEncodableCollection {
    func encode(to stream: StreamWriter) throws {
        guard items.count > 0 else {
            return
        }
        try stream.withSubStreamWriter(sizedBy: LengthType.self) { stream in
            for value in self.items {
                try value.encode(to: stream)
            }
        }
    }
}
