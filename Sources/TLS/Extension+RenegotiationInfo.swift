import Stream

extension Extension {
    public struct RenegotiationInfo: Equatable {
        let values: [Any]

        public static func ==(
            lhs: RenegotiationInfo,
            rhs: RenegotiationInfo) -> Bool
        {
            return lhs.values.isEmpty == rhs.values.isEmpty
        }
    }
}

extension Extension.RenegotiationInfo {
    init<T: StreamReader>(from stream: T) throws {
        let length = try stream.read(UInt8.self)

        guard length > 0 else {
            self.values = []
            return
        }

        fatalError("not implemented")
    }
}
