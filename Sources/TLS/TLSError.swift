public enum TLSError: Error {
    case invalidRecordContentType
    case invalidProtocolVerion
    case invalidHandshakeType
    case invalidHandshake
    case invalidCertificateStatus
    case invalidCiperSuitesLength
    case invalidCiperSuite
    case invalidCompressionMethod
    case invalidExtension
    case invalidClientHelloExtension
    case invalidServerHelloExtension
    case invalidEncryptedExtension
    case invalidChangeCiperSpec
    case invalidEarlyDataIndication
    case invalidAlert
}
