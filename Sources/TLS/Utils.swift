import Stream

extension StreamReader {
    func withLimitedStream<T>(
        by byteCount: Int,
        body: (UnsafeRawInputStream) throws -> T) throws -> T
    {
        return try read(count: byteCount) { bytes in
            let stream = UnsafeRawInputStream(
                pointer: bytes.baseAddress!,
                count: bytes.count)
            return try body(stream)
        }
    }
}

extension StreamWriter {
    // TODO: avoid copying
    func countingLength<T: FixedWidthInteger>(
        as type: T.Type,
        task: (OutputByteStream) throws -> Void) throws
    {
        let output = OutputByteStream()
        try task(output)
        try write(T(output.bytes.count))
        try write(output.bytes)
    }

    // TODO: avoid copying
    func countingLength(
        as type: UInt24.Type,
        task: (OutputByteStream) throws -> Void) throws
    {
        let output = OutputByteStream()
        try task(output)
        try write(UInt24(UInt(output.bytes.count)))
        try write(output.bytes)
    }
}
