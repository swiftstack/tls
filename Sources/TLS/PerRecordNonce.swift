public class PerRecordNonce {
    let baseIV: [UInt8]
    var sequenceNumber: UInt64

    public var nextIV: [UInt8] {
        var result = baseIV
        result ^= sequenceNumber
        sequenceNumber += 1
        return result
    }

    public init(baseIV: [UInt8]) {
        // An AEAD algorithm where N_MAX is less than 8 bytes
        //    MUST NOT be used with TLS.
        precondition(baseIV.count >= 8)
        self.baseIV = baseIV
        self.sequenceNumber = 0
    }
}

extension Array where Element == UInt8 {
    fileprivate static func ^= (lhs: inout Self, rhs: UInt64) {
        lhs.withUnsafeMutableBufferPointer { buffer in
            Swift.withUnsafeBytes(of: rhs.bigEndian) { bytes in
                for i in 0..<8 {
                    buffer[buffer.count - 8 + i] ^= bytes[i]
                }
            }
        }
    }
}

extension PerRecordNonce: Equatable {
    public static func == (lhs: PerRecordNonce, rhs: PerRecordNonce) -> Bool {
        return lhs.baseIV == rhs.baseIV
            && lhs.sequenceNumber == rhs.sequenceNumber
    }
}
