import Stream

extension Extension {
    public struct Unknown: Equatable, Sendable {
        let rawType: UInt16
        let content: [UInt8]

        public init(rawType: UInt16, content: [UInt8]) {
            self.rawType = rawType
            self.content = content
        }
    }
}
