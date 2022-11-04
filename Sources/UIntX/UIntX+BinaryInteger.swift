import Foundation

extension UIntX: BinaryInteger {

    public var bitWidth: Int { parts.count * Element.bitWidth }

    public var words: [UInt] {

        guard bitWidth <= UInt.bitWidth else { return parts.reversed().flatMap(\.words) }

        return [
            parts.reversed()
                .map { UInt($0) }
                .enumerated()
                .map { $1 << ($0 * Element.bitWidth) }
                .reduce(0, +)
        ]
    }

    public var trailingZeroBitCount: Int {

        var result: Int = 0
        for value in parts.reversed() {

            result += value.trailingZeroBitCount
            if value.trailingZeroBitCount < value.bitWidth { break }
        }
        return result
    }

    public var leadingZeroBitCount: Int {

        var bitCount = 0
        for value in parts {

            bitCount += value.leadingZeroBitCount
            if value.leadingZeroBitCount < value.bitWidth { break }
        }
        return bitCount
    }

    public init<T>(_ source: T) where T: BinaryInteger {

        self.init(littleEndianArray: Array(source.words))
    }

    public init<T>(clamping source: T) where T: BinaryInteger {

        self.init(littleEndianArray: Array(source.words))
    }

    public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {

        self.init(littleEndianArray: Array(source.words))
    }

    public init?<T>(exactly source: T) where T: BinaryFloatingPoint {

        guard let value = UInt(exactly: round(source)) else { return nil }
        self.init(value)
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {

        self.init(UInt(source))
    }

    public static prefix func ~ (value: UIntX<Element>) -> UIntX<Element> {

        var mutatable = UIntX<Element>(value)
        mutatable.parts = mutatable.parts.map(~)
        return mutatable
    }

    public static func >>= <RHS>(lhs: inout UIntX<Element>, rhs: RHS) where RHS: BinaryInteger {

        guard rhs < RHS(lhs.bitWidth) else {

            lhs.parts = [Element.zero]
            return
        }

        let remainder = Int(rhs) % Element.bitWidth
        let multiple = Int(rhs) / Element.bitWidth

        var result: [Element] = []
        for index in 0 ..< (lhs.parts.count - multiple) {

            var value = lhs.parts[index] >> remainder
            if index > 0 {

                value |= lhs.parts[index - 1] << (Element.bitWidth - remainder)
            }
            result.append(value)
        }

        lhs.parts = result
    }

    public static func <<= <RHS>(lhs: inout UIntX<Element>, rhs: RHS) where RHS: BinaryInteger {

        guard rhs > 0 else { return }
        var missingLeadingParts = 0
        if lhs.leadingZeroBitCount < rhs {

            let overflowBits = Int(rhs) - lhs.leadingZeroBitCount
            missingLeadingParts = (overflowBits - 1) / Element.bitWidth + 1
        }

        let remainder = Int(rhs) % Element.bitWidth
        let multiple = Int(rhs) / Element.bitWidth

        var result = [Element](repeating: .zero, count: lhs.parts.count + missingLeadingParts)
        for index in multiple ..< (lhs.parts.count + missingLeadingParts) {

            let value: Element
            if remainder > 0 {
                if index - missingLeadingParts == -1 {
                    value = lhs.parts[index - missingLeadingParts + 1] >> (Element.bitWidth - remainder)
                } else if index - missingLeadingParts == lhs.parts.count - 1 {
                    value = lhs.parts[index - missingLeadingParts] << remainder
                } else {
                    value = (lhs.parts[index - missingLeadingParts] << remainder) | (lhs.parts[index - missingLeadingParts + 1] >> (Element.bitWidth - remainder))
                }
            } else {
                value = lhs.parts[index - multiple]
            }
            result[index - multiple] = value
        }

        lhs.parts = result.removingOverflow().result
    }

    public static func &= (lhs: inout UIntX, rhs: UIntX) {

        let minCount = Swift.min(lhs.parts.count, rhs.parts.count)
        var values = [Element](repeating: .zero, count: minCount)
        for index in 0 ..< minCount {
            values[minCount - 1 - index] = lhs.parts[lhs.parts.count - 1 - index] & rhs.parts[rhs.parts.count - 1 - index]
        }

        lhs.parts = values.removingFirst(where: { $0 == 0 })
        if lhs.parts.isEmpty {
            lhs.parts = [.zero]
        }
    }

    public static func |= (lhs: inout UIntX, rhs: UIntX) {

        let maxCount = Swift.max(lhs.parts.count, rhs.parts.count)
        var values: [Element]
        if lhs.parts.count > rhs.parts.count {
            values = lhs.parts
        } else if lhs.parts.count < rhs.parts.count {
            values = rhs.parts
        } else {
            values = [Element](repeating: .zero, count: maxCount)
        }

        for index in 0 ..< maxCount {
            guard
                index < lhs.parts.count,
                index < rhs.parts.count
            else { break }
            values[maxCount - 1 - index] = lhs.parts[lhs.parts.count - 1 - index] | rhs.parts[rhs.parts.count - 1 - index]
        }

        lhs.parts = values
    }

    public static func ^= (lhs: inout UIntX, rhs: UIntX) {

        let maxCount = Swift.max(lhs.parts.count, rhs.parts.count)
        var values: [Element]
        if lhs.parts.count > rhs.parts.count {
            values = lhs.parts
        } else if lhs.parts.count < rhs.parts.count {
            values = rhs.parts
        } else {
            values = [Element](repeating: .zero, count: maxCount)
        }

        for index in 0 ..< maxCount {
            guard
                index < lhs.parts.count,
                index < rhs.parts.count
            else { break }
            values[maxCount - 1 - index] = lhs.parts[lhs.parts.count - 1 - index] ^ rhs.parts[rhs.parts.count - 1 - index]
        }

        lhs.parts = values.removingFirst(where: { $0 == 0 })
        if lhs.parts.isEmpty {
            lhs.parts = [.zero]
        }
    }
}
