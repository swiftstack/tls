import Stream

protocol StreamDecodable {
    static func decode(from stream: StreamReader) async throws -> Self
}

protocol StreamEncodable {
    func encode(to stream: StreamWriter) async throws
}

protocol StreamDecodableCollection: StreamDecodable {
    associatedtype LengthType: FixedWidthInteger
    associatedtype Element: StreamDecodable

    init(_ items: [Element])
}

protocol StreamEncodableCollection: StreamEncodable {
    associatedtype LengthType: FixedWidthInteger
    associatedtype Element: StreamEncodable

    var items: [Element] { get }
}

protocol StreamCodable: StreamEncodable, StreamDecodable {}
protocol StreamCodableCollection:
    StreamEncodableCollection,
    StreamDecodableCollection {}

extension StreamDecodableCollection {
    static func decode(from stream: StreamReader) async throws -> Self {
        let items = try await stream.withSubStreamReader(
            sizedBy: LengthType.self
        ) { sub -> [Element] in
            var items = [Element]()
            while !sub.isEmpty {
                items.append(try await Element.decode(from: sub))
            }
            return items
        }
        return .init(items)
    }
}

extension StreamEncodableCollection {
    func encode(to stream: StreamWriter) async throws {
        try await stream.withSubStreamWriter(sizedBy: LengthType.self) { sub in
            for value in items {
                try await value.encode(to: sub)
            }
        }
    }
}
