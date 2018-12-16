struct GenericBlockCipher {
    let content: [UInt8] // SSLCompressed.length
    let MAC: [UInt8] // CipherSpec.hash_size
    let padding: [UInt8] //GenericBlockCipher.padding_length
    let padding_length: UInt8
}

// For block ciphers (such as RC2 or DES), the encryption and MAC
//    functions convert SSLCompressed.fragment structures to and from block
//    SSLCiphertext.fragment structures.
//
//         block-ciphered struct {
//             opaque content[SSLCompressed.length];
//             opaque MAC[CipherSpec.hash_size];
//             uint8 padding[GenericBlockCipher.padding_length];
//             uint8 padding_length;
//         } GenericBlockCipher;
//
//    The MAC is generated as described in Section 5.2.3.1.
//
//    padding:  Padding that is added to force the length of the plaintext
//       to be a multiple of the block cipher's block length.
//
//    padding_length:  The length of the padding must be less than the
//       cipher's block length and may be zero.  The padding length should
//       be such that the total size of the GenericBlockCipher structure is
//       a multiple of the cipher's block length.
//
//    The encrypted data length (SSLCiphertext.length) is one more than the
//    sum of SSLCompressed.length, CipherSpec.hash_size, and
//    padding_length.
//
//    Note: With CBC, the initialization vector (IV) for the first record
//    is provided by the handshake protocol.  The IV for subsequent records
//    is the last ciphertext block from the previous record.
//
