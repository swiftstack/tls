extension PublicKey {
    var bytes: [UInt8] {
        .init(self.rawRepresentation)
    }
}

extension PublicKey: @retroactive Equatable {
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        lhs.rawRepresentation == rhs.rawRepresentation
    }
}
