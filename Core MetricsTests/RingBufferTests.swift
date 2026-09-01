import Testing
@testable import Core_Metrics

@Suite("Ring buffer")
struct RingBufferTests {
    @Test("Starts empty")
    func startsEmpty() {
        let buffer = RingBuffer<Int>(capacity: 3)
        #expect(buffer.capacity == 3)
        #expect(buffer.count == 0)
        #expect(buffer.isEmpty)
        #expect(!buffer.isFull)
        #expect(buffer.elements == [])
    }

    @Test("Preserves append order before reaching capacity")
    func appendsInOrder() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.append(1)
        buffer.append(2)

        #expect(buffer.count == 2)
        #expect(buffer.elements == [1, 2])
    }

    @Test("Evicts the oldest element and keeps chronological order")
    func wrapsInOrder() {
        var buffer = RingBuffer<Int>(capacity: 3)
        for value in 1...5 {
            buffer.append(value)
        }

        #expect(buffer.count == 3)
        #expect(buffer.isFull)
        #expect(buffer.elements == [3, 4, 5])
    }

    @Test("Capacity one retains only the latest element")
    func capacityOne() {
        var buffer = RingBuffer<String>(capacity: 1)
        buffer.append("first")
        buffer.append("second")
        #expect(buffer.elements == ["second"])
    }

    @Test("removeAll resets indices and keeps capacity")
    func removesAll() {
        var buffer = RingBuffer<Int>(capacity: 2)
        buffer.append(1)
        buffer.append(2)
        buffer.removeAll()
        buffer.append(3)

        #expect(buffer.capacity == 2)
        #expect(buffer.count == 1)
        #expect(buffer.elements == [3])
    }
}
