// https://tools.ietf.org/html/rfc6101#section-5.1
struct Connection {
    let random: [UInt8]
    let serverMACSecret: [UInt8]
    let clientMACSecret: [UInt8]
    let serverWriteKey: [UInt8]
    let clientWriteKey: [UInt8]
    let initializationVectors: [UInt8]
    let sequenceNumbers: [UInt8]
}
