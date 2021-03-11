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
    case invalidServerHelloRecord
    case invalidClientHelloExtension
    case invalidClientHelloRecord
    case invalidServerHelloExtension
    case invalidEncryptedExtension
    case invalidChangeCiperSpec
    case invalidKeyExchange
    case invalidTranscriptHash
    case invalidEarlyDataIndication
    case invalidAlert

    case unexpectedRecordContentType
    case handshakeFailed
}
