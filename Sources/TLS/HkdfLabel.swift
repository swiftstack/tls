import Stream
import CryptoKit

struct HkdfLabel {
    let length: Int
    let label: Label
    let context: [UInt8]

    enum Label: String {
        case externalPSKBinder = "ext binder"
        case resumptionPSKBinder = "res binder"
        case clientEarlyTraffic = "c e traffic"
        case earlyExporterMaster = "e exp master"
        case derived = "derived"
        case clientHandshakeTraffic = "c hs traffic"
        case serverHandshakeTraffic = "s hs traffic"
        case clientApplicationTraffic = "c ap traffic"
        case serverApplicationTraffic = "s ap traffic"
        case exporterMaster = "exp master"
        case resumptionMaster = "res master"
        case resumption = "resumption"
        case finished = "finished"
        case clientCertificateVerify = "TLS 1.3, client CertificateVerify"
        case serverCertificateVerify = "TLS 1.3, server CertificateVerify"
        case key = "key"
        case iv = "iv"
    }

    var rawRepresentation: [UInt8] {
        let label = "tls13 " + self.label.rawValue

        precondition(label.utf8.count <= UInt8.max)
        precondition(context.count <= UInt8.max)

        // TODO: manual encoding
        let stream = MemoryStream()

        try? stream.write(UInt16(length))

        try? stream.write(UInt8(label.utf8.count))
        try? stream.write(label)

        try? stream.write(UInt8(context.count))
        try? stream.write(context)

        return stream.withUnsafeBufferPointer([UInt8].init)
    }
}
