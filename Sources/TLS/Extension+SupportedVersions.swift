import Stream

extension Extension {
    public struct SupportedVersions: Equatable {
        let items: [Version]

        init(_ items: [Version]) {
            self.items = items
        }
    }
}

extension Extension.SupportedVersions: StreamCodableCollection {
    typealias LengthType = UInt8
}

extension Extension.SupportedVersions: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Version...) {
        self.init([Version](elements))
    }
}
