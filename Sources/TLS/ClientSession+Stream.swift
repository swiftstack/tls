import Stream

extension ClientSession: Stream {
    func read(
        to pointer: UnsafeMutableRawPointer,
        byteCount: Int
    ) async throws -> Int {
        let nextRecord = try await receive()
        guard nextRecord.count <= byteCount else {
            throw StreamError.notEnoughSpace
        }
        pointer.copyMemory(from: nextRecord, byteCount: nextRecord.count)
        return nextRecord.count
    }

    func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int
    ) async throws -> Int {
        try await send(UnsafeRawBufferPointer(start: buffer, count: byteCount))
        return byteCount
    }
}
