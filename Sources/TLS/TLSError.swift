public enum TLSError: Error {
    case invalidRecordContentType
    case invalidProtocolVerion
    case invalidHandshake
    case invalidCertificateStatus
    case invalidCiperSuitesLength
    case invalidCiperSuite
    case invalidCompressionMethod
    case invalidExtension
    case invalidChangeCiperSpec
    case invalidAlert
}
