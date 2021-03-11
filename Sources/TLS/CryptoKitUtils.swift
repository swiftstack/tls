import CryptoKit

// MARK: @testable

extension SymmetricKey {
    var bytes: [UInt8] {
        self.withUnsafeBytes{ [UInt8]($0) }
    }
}

extension SymmetricKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        self.init(data: parse(string))
    }
}

extension PrivateKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

extension PublicKey: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

// parse hex string from rfc examples
func parse(_ string: String) -> [UInt8] {
    .init(decodingHex: string.filter { !$0.isWhitespace })!
}
