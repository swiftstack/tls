public enum TLSError: Error {
    case invalidRecordContentType
    case invalidHandshake
    case invalidProtocolVerion
    case invalidCiperSuitesLength
    case invalidCiperSuite
    case invalidCompressionMethod
    case invalidExtension
    case invalidChangeCiperSpec
    case invalidAlert
}
