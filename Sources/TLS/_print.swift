import CryptoKit

func print(_ key: SymmetricKey) {
    print(key.withUnsafeBytes([UInt8].init))
}

func print(_ key: PerRecordNonce) {
    print(key.baseIV)
}

func print(_ key: HMAC<SHA256>.MAC) {
    print(key.withUnsafeBytes([UInt8].init))
}

func print(_ bytes: [UInt8]) {
    print(String(encodingToHex: bytes))
}

func print(_ label: StaticString = "", _ key: SymmetricKey) {
    print(label, key.withUnsafeBytes([UInt8].init))
}

func print(_ label: StaticString = "", _ key: HMAC<SHA256>.MAC) {
    print(label, key.withUnsafeBytes([UInt8].init))
}

func print(_ label: StaticString = "", _ bytes: [UInt8]) {
    print(label, String(encodingToHex: bytes))
}
