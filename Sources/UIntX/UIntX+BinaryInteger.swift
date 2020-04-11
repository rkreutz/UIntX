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

        self.init(ascendingArray: Array(source.words))
    }

    public init<T>(clamping source: T) where T: BinaryInteger {

        self.init(ascendingArray: Array(source.words))
    }

    public init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {

        self.init(ascendingArray: Array(source.words))
    }

    public init?<T>(exactly source: T) where T: BinaryFloatingPoint {

        guard let value = UInt(exactly: round(source)) else { return nil }
        self.init(value)
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {

        self.init(UInt(source))
    }

    public static prefix func ~ (value: UIntX<Element>) -> UIntX<Element> {

        UIntX<Element>(ascendingArray: value.parts.reversed().map(~))
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

        if lhs.leadingZeroBitCount < rhs {

            let overflowBits = Int(rhs) - lhs.leadingZeroBitCount
            let missingLeadingParts = overflowBits / Element.bitWidth + 1
            (0 ..< missingLeadingParts).forEach { _ in

                lhs.parts = [0] + lhs.parts
            }
        }

        let remainder = Int(rhs) % Element.bitWidth
        let multiple = Int(rhs) / Element.bitWidth

        var result: [Element] = []
        for index in multiple ..< lhs.parts.count {

            var value = lhs.parts[index] << remainder
            if index < (lhs.parts.count - 1) {

                value |= lhs.parts[index + 1] >> (Element.bitWidth - remainder)
            }
            result.append(value)
        }

        for _ in (0 ..< multiple) {

            result.append(0)
        }

        lhs.parts = result.removingOverflow().result
    }

    public static func &= (lhs: inout UIntX, rhs: UIntX) {

        var values = [Element]()
        for (offset, lhsPart) in lhs.parts.reversed().enumerated() {

            guard let rhsPart = rhs.parts.reversed().at(index: offset) else { break }
            values.append(lhsPart & rhsPart)
        }

        lhs = UIntX<Element>(ascendingArray: values)
    }

    public static func |= (lhs: inout UIntX, rhs: UIntX) {

        let max = Swift.max(lhs, rhs)
        let min = Swift.min(lhs, rhs)
        var values = [Element]()
        for (offset, maxPart) in max.parts.reversed().enumerated() {

            if let minPart = min.parts.reversed().at(index: offset) {

                values.append(maxPart | minPart)
            } else {

                values.append(maxPart)
            }
        }

        lhs = UIntX<Element>(ascendingArray: values)
    }

    public static func ^= (lhs: inout UIntX, rhs: UIntX) {

        let max = Swift.max(lhs, rhs)
        let min = Swift.min(lhs, rhs)
        var values = [Element]()
        for (offset, maxPart) in max.parts.reversed().enumerated() {

            if let minPart = min.parts.reversed().at(index: offset) {

                values.append(maxPart ^ minPart)
            } else {

                values.append(maxPart)
            }
        }

        lhs = UIntX<Element>(ascendingArray: values)
    }
}
