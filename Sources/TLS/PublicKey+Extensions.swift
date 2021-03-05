extension PublicKey {
    var bytes: [UInt8] {
        .init(self.rawRepresentation)
    }
}

extension PublicKey: Equatable {
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        lhs.rawRepresentation == rhs.rawRepresentation
    }
}

extension PublicKey: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        try! self.init(rawRepresentation: elements)
    }
}
