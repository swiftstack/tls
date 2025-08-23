import TLS
import CryptoKit

extension SymmetricKey {
    var bytes: [UInt8] {
        self.withUnsafeBytes { [UInt8]($0) }
    }
}

extension SymmetricKey: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        self.init(data: parse(string))
    }
}

extension PrivateKey: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

extension PublicKey: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        try! self.init(rawRepresentation: parse(string))
    }
}

extension PublicKey: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        try! self.init(rawRepresentation: elements)
    }
}

// parse hex string from rfc examples
func parse(_ string: String) -> [UInt8] {
    .init(decodingHex: string.filter { !$0.isWhitespace })!
}
