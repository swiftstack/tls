struct GenericStreamCipher {
    let content: [UInt8] // SSLCompressed.length
    let MAC: [UInt8] // CipherSpec.hash_size
}
