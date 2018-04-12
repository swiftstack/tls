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

    init(from stream: StreamReader) throws {
        let rawType = try stream.read(UInt8.self)
        guard let type = CurveType(rawValue: rawType) else {
            throw TLSError.invalidExtension
        }
        self = type
    }

    func encode(to stream: StreamWriter) throws {
        try stream.write(rawValue)
    }
}

extension ServerKeyExchange {
    typealias SupportedGroup = Extension.SupportedGroup
    typealias SignatureAlgorithm = Extension.SignatureAlgorithm

    init(from stream: StreamReader) throws {
        _ = try CurveType(from: stream)
        self.curve = try SupportedGroup(from: stream)
        let pubkeyLength = Int(try stream.read(UInt8.self))
        self.pubkey = try stream.read(count: pubkeyLength)
        self.algorithm = try SignatureAlgorithm(from: stream)
        let signatureLength = Int(try stream.read(UInt16.self))
        self.signature = try stream.read(count: signatureLength)
    }

    func encode(to stream: StreamWriter) throws {
        try CurveType.namedCurve.encode(to: stream)
        try curve.encode(to: stream)
        try stream.write(UInt8(pubkey.count))
        try stream.write(pubkey)
        try algorithm.encode(to: stream)
        try stream.write(UInt16(signature.count))
        try stream.write(signature)
    }
}
