import CryptoKit

extension HKDF {
    // HKDF-Expand-Label(Secret, Label, Context, Length) =
    //      HKDF-Expand(Secret, HkdfLabel, Length)
    static func expandLabel(
        pseudoRandomKey key: SymmetricKey,
        label: HkdfLabel.Label,
        context: [UInt8],
        length: Int
    ) -> SymmetricKey where H : HashFunction {
        let label = HkdfLabel(length: length, label: label, context: context)
        return HKDF<H>.expand(
            pseudoRandomKey: key,
            info: label.rawRepresentation,
            outputByteCount: length)
    }

    // Derive-Secret(Secret, Label, Messages) =
    //      HKDF-Expand-Label(Secret, Label,
    //                       Transcript-Hash(Messages), Hash.length)
    static func deriveKey(
        inputKeyMaterial key: SymmetricKey,
        label: HkdfLabel.Label,
        digest: H.Digest
    ) -> SymmetricKey where H : HashFunction {
        return HKDF<H>.expandLabel(
            pseudoRandomKey: key,
            label: label,
            context: .init(digest),
            length: H.Digest.byteCount)
    }
}
