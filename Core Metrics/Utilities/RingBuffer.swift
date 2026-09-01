import Foundation

/// A fixed-capacity, insertion-ordered buffer with O(1) append.
nonisolated struct RingBuffer<Element: Sendable>: Sendable {
    let capacity: Int

    private var storage: [Element?]
    private var nextInsertionIndex = 0
    private(set) var count = 0

    init(capacity: Int) {
        precondition(capacity > 0, "RingBuffer capacity must be greater than zero")
        self.capacity = capacity
        storage = Array(repeating: nil, count: capacity)
    }

    var isEmpty: Bool {
        count == 0
    }

    var isFull: Bool {
        count == capacity
    }

    /// Elements from oldest to newest.
    var elements: [Element] {
        guard count > 0 else {
            return []
        }

        let oldestIndex = isFull ? nextInsertionIndex : 0
        var result: [Element] = []
        result.reserveCapacity(count)

        for offset in 0..<count {
            let index = (oldestIndex + offset) % capacity
            if let element = storage[index] {
                result.append(element)
            }
        }

        return result
    }

    mutating func append(_ element: Element) {
        storage[nextInsertionIndex] = element
        nextInsertionIndex = (nextInsertionIndex + 1) % capacity
        count = min(count + 1, capacity)
    }

    mutating func removeAll() {
        storage = Array(repeating: nil, count: capacity)
        nextInsertionIndex = 0
        count = 0
    }
}
