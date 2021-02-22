extension Extension {
    enum RawType: UInt16 {
        case serverName = 0x0000
        case maxFragmentLength = 0x0001
        case clientCertificateUrl = 0x0002
        case trustedCAKeys = 0x0003
        case truncatedHMAC = 0x0004
        case statusRequest = 0x0005
        case userMapping = 0x0006
        case clientAuthz = 0x0007
        case serverAuthz = 0x0008
        case certType = 0x0009
        case supportedGroups = 0x000a // (ex "elliptic_curves")
        case ecPointFormats = 0x000b
        case srp = 0x000c
        case signatureAlgorithms = 0x000d
        case useSrtp = 0x000e
        case heartbeat = 0x000f
        case alpn = 0x0010
        case statusRequestV2 = 0x0011
        case signedCertificateTimestamp = 0x0012
        case clientCertificateType = 0x0013
        case serverCertificateType = 0x0014
        case padding = 0x0015
        case encryptThenMac = 0x0016
        case extendedMasterSecret = 0x0017
        case tokenBinding = 0x0018 // (TEMPORARY - registered 2016-02-04, expires 2017-02-04)
        case cachedInfo  = 0x0019
        case recordSizeLimit = 0x001c
        case sessionTicket = 0x0023
        case preSharedKey = 0x0029
        case earlyData = 0x002a
        case supportedVersions = 0x002b
        case cookie = 0x002c
        case pskKeyExchangeModes = 0x002d
        case certificateAuthorities = 0x002f
        case oidFilters = 0x0030
        case postHandshakeAuth = 0x0031
        case signatureAlgorithmsCert = 0x0032
        case keyShare = 0x0033
        case nextProtocolNegotiation = 0x3374
        case renegotiationInfo = 0xFF01
    }
}
