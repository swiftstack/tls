struct UInt24: Equatable {
    fileprivate let low: UInt8
    fileprivate let middle: UInt8
    fileprivate let hight: UInt8
}

extension UInt {
    init(_ value: UInt24) {
        self =
            (UInt(value.hight) << 16) |
            (UInt(value.middle) << 8) |
            (UInt(value.low))
    }
}

extension Int {
    init(_ value: UInt24) {
        self =
            (Int(value.hight) << 16) |
            (Int(value.middle) << 8) |
            (Int(value.low))
    }
}

extension UInt24 {
    /// Convert from Swift's unsigned integer type, trapping on overflow.
    init(_ value: UInt) {
        precondition(value <= 0xFFFFFF)
        self.init(truncatingIfNeeded: value)
    }

    /// Construct a `UInt24` having the same bitwise representation as
    /// the least significant bits of the provided bit pattern.
    ///
    /// No range or overflow checking occurs.
    init(truncatingIfNeeded value: UInt) {
        hight = UInt8(truncatingIfNeeded: value >> 16)
        middle = UInt8(truncatingIfNeeded: value >> 8)
        low = UInt8(truncatingIfNeeded: value)
    }
}

extension UInt24 {
    var byteSwapped: UInt24 {
        return UInt24(low: self.hight, middle: self.middle, hight: self.low)
    }
}

extension UInt24: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt) {
        self = UInt24(value)
    }
}

extension UInt24: CustomStringConvertible {
    public var description: String {
        return UInt(self).description
    }
}
