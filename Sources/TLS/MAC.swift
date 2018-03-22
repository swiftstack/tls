struct MD5 {
    static let pad1 = [UInt8](repeating: 0x36, count: 48)
    static let pad2 = [UInt8](repeating: 0x5c, count: 48)
}

struct SHA {
    static let pad1 = [UInt8](repeating: 0x36, count: 40)
    static let pad2 = [UInt8](repeating: 0x5c, count: 40)
}

//The MAC is generated as:
//
//        hash(MAC_write_secret + pad_2 +
//             hash(MAC_write_secret + pad_1 + seq_num +
//                  SSLCompressed.type + SSLCompressed.length +
//                  SSLCompressed.fragment));
//
//   where "+" denotes concatenation.
//
//   pad_1:  The character 0x36 repeated 48 times for MD5 or 40 times for
//      SHA.
//
//   pad_2:  The character 0x5c repeated 48 times for MD5 or 40 times for
//      SHA.
//
//   seq_num:  The sequence number for this message.
//
//   hash:  Hashing algorithm derived from the cipher suite.
//
//   Note that the MAC is computed before encryption.  The stream cipher
//   encrypts the entire block, including the MAC.  For stream ciphers
//   that do not use a synchronization vector (such as RC4), the stream
//   cipher state from the end of one record is simply used on the
//   subsequent packet.  If the CipherSuite is SSL_NULL_WITH_NULL_NULL,
//   encryption consists of the identity operation (i.e., the data is not
//   encrypted and the MAC size is zero implying that no MAC is used).
//   SSLCiphertext.length is SSLCompressed.length plus
//   CipherSpec.hash_size.
//
