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
        ) { stream -> [Certificate] in
            var items = [Certificate]()
            while !stream.isEmpty {
                items.append(try await Certificate.decode(from: stream))
            }
            return items
        }

        return .init(context: context, sertificates: sertificates)
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(context)
        try await stream.withSubStreamWriter(sizedBy: UInt24.self)
        { stream in
            for value in self.sertificates {
                try await value.encode(to: stream)
            }
        }
    }
}

extension Certificate {
    public static func decode(from stream: StreamReader) async throws -> Self {
        let bytes = try await stream.withSubStreamReader(sizedBy: UInt24.self)
        { stream in
            return try await stream.readUntilEnd()
        }
        let ext = try await stream.withSubStreamReader(sizedBy: UInt16.self)
        { stream in
            return try await stream.readUntilEnd()
        }
        return .init(bytes: bytes, extensions: ext)
    }

    public func encode(to stream: StreamWriter) async throws {
        try await stream.withSubStreamWriter(sizedBy: UInt24.self)
        { stream in
            try await stream.write(bytes)
        }
        try await stream.withSubStreamWriter(sizedBy: UInt16.self)
        { stream in
            try await stream.write(extensions)
        }
    }
}
