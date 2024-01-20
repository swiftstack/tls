import UInt24
import Stream

public struct Certificates: Equatable {
    let context: UInt8
    let sertificates: [Certificate]
}

public struct Certificate: Equatable {
    let bytes: [UInt8]
    let extensions: [UInt8]
}

extension Certificates: StreamCodable {
    static func decode(from stream: StreamReader) async throws -> Self {
        let context = try await stream.read(UInt8.self)

        let sertificates = try await stream.withSubStreamReader(
            sizedBy: UInt24.self
        ) { sub -> [Certificate] in
            var items = [Certificate]()
            while !sub.isEmpty {
                items.append(try await Certificate.decode(from: sub))
            }
            return items
        }

        return .init(context: context, sertificates: sertificates)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(context)
        try await stream.withSubStreamWriter(sizedBy: UInt24.self) { sub in
            for value in sertificates {
                try await value.encode(to: sub)
            }
        }
    }
}

extension Certificate {
    public static func decode(from stream: StreamReader) async throws -> Self {
        let bytes = try await stream.withSubStreamReader(
            sizedBy: UInt24.self
        ) { sub in
            try await sub.readUntilEnd()
        }
        let ext = try await stream.withSubStreamReader(
            sizedBy: UInt16.self
        ) { sub in
            return try await sub.readUntilEnd()
        }
        return .init(bytes: bytes, extensions: ext)
    }

    public func encode(to stream: StreamWriter) async throws {
        try await stream.withSubStreamWriter(sizedBy: UInt24.self) { sub in
            try await sub.write(bytes)
        }
        try await stream.withSubStreamWriter(sizedBy: UInt16.self) { sub in
            try await sub.write(extensions)
        }
    }
}
