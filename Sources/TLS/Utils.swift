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
        try write(T(output.bytes.count).byteSwapped)
        try write(output.bytes)
    }
}

extension StreamReader {
    func read(_ type: UInt24.Type) throws -> UInt24 {
        var value = UInt24(0)
        try withUnsafeMutableBytes(of: &value) { buffer in
            try read(count: MemoryLayout<UInt24>.size) { bytes in
                buffer.copyMemory(from: bytes)
            }
        }
        return value
    }
}

extension StreamWriter {
    func write(_ type: UInt24) throws {
        var value = UInt24(0)
        try withUnsafePointer(to: &value) { pointer in
            try write(pointer, byteCount: MemoryLayout<UInt24>.size)
        }
    }
}
