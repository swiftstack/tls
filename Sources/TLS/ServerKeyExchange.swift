import Stream

public struct ServerKeyExchange: Equatable {
    public enum CurveType: UInt8 {
        case namedCurve = 0x03
    }

    public let curve: Extension.SupportedGroup
    public let pubkey: [UInt8]
    public let algorithm: Extension.SignatureAlgorithm
    public let signature: [UInt8]

    public init(
        curve: Extension.SupportedGroup,
        pubkey: [UInt8],
        algorithm: Extension.SignatureAlgorithm,
        signature: [UInt8])
    {
        self.curve = curve
        self.pubkey = pubkey
        self.algorithm = algorithm
        self.signature = signature
    }
}

extension ServerKeyExchange.CurveType {
    typealias CurveType = ServerKeyExchange.CurveType

    static func decode(from stream: StreamReader) async throws -> Self {
        let rawType = try await stream.read(UInt8.self)
        guard let type = CurveType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        return type
    }

    func encode(to stream: StreamWriter) async throws {
        try await stream.write(rawValue)
    }
}

extension ServerKeyExchange {
    typealias SupportedGroup = Extension.SupportedGroup
    typealias SignatureAlgorithm = Extension.SignatureAlgorithm

    static func decode(from stream: StreamReader) async throws -> Self {
        _ = try await CurveType.decode(from: stream)
        let curve = try await SupportedGroup.decode(from: stream)
        let pubkeyLength = Int(try await stream.read(UInt8.self))
        let pubkey = try await stream.read(count: pubkeyLength)
        let algorithm = try await SignatureAlgorithm.decode(from: stream)
        let signatureLength = Int(try await stream.read(UInt16.self))
        let signature = try await stream.read(count: signatureLength)
        return .init(
            curve: curve,
            pubkey: pubkey,
            algorithm: algorithm,
            signature: signature)
    }

    func encode(to stream: StreamWriter) async throws {
        try await CurveType.namedCurve.encode(to: stream)
        try await curve.encode(to: stream)
        try await stream.write(UInt8(pubkey.count))
        try await stream.write(pubkey)
        try await algorithm.encode(to: stream)
        try await stream.write(UInt16(signature.count))
        try await stream.write(signature)
    }
}
