/// A sendable boundary around aggregate host CPU tick acquisition.
nonisolated protocol CPUTicksReading: Sendable {
    func readTicks() throws -> CPUTicks
}
