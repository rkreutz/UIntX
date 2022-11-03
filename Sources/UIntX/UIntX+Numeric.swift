extension UIntX: Numeric {

    public var magnitude: UIntX { self }

    public init<Value>(exactly source: Value) where Value: BinaryInteger {

        self.init(littleEndianArray: Array(source.words))
    }

    // MARK: - Addition

    public func addingReportingOverflow(_ rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        let maxCount = Swift.max(parts.count, rhs.parts.count)
        var values: [Element]
        if parts.count > rhs.parts.count {
            values = parts
        } else if parts.count < rhs.parts.count {
            values = rhs.parts
        } else {
            values = [Element](repeating: .zero, count: maxCount)
        }
        var carriedOver: Element = 0

        for index in 0 ..< maxCount {

            guard
                index < parts.count,
                index < rhs.parts.count
            else {
                let (result, overflow) = values[maxCount - 1 - index].addingReportingOverflow(carriedOver)
                values[maxCount - 1 - index] = result
                if overflow {
                    carriedOver = 1
                    continue
                } else {
                    carriedOver = 0
                    break
                }
            }
            let (result1, overflow1) = parts[parts.count - 1 - index].addingReportingOverflow(rhs.parts[rhs.parts.count - 1 - index])
            let (result2, overflow2) = result1.addingReportingOverflow(carriedOver)
            values[maxCount - 1 - index] = result2
            carriedOver = overflow1 || overflow2 ? 1 : 0
        }

        if carriedOver > 0 { values = [carriedOver] + values }

        let (limitedValues, overflow) = values.removingOverflow()
        var value = UIntX()
        value.parts = limitedValues
        return (value, overflow)
    }

    public static func + (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.addingReportingOverflow(rhs).partialValue }
    public static func += (lhs: inout UIntX, rhs: UIntX) { lhs = lhs + rhs }

    // MARK: - Subtraction

    public func subtractingReportingOverflow(_ rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        let maxCount = Swift.max(parts.count, rhs.parts.count)
        var values = [Element](repeating: .zero, count: maxCount)
        var carriedOver: Element = 0

        for index in 0 ..< maxCount {

            let lhsPart = parts.at(index: parts.count - 1 - index) ?? 0
            let rhsPart = rhs.parts.at(index: rhs.parts.count - 1 - index) ?? 0
            let (result1, overflow1) = lhsPart.subtractingReportingOverflow(rhsPart)
            let (result2, overflow2) = result1.subtractingReportingOverflow(carriedOver)

            values[maxCount - 1 - index] = result2
            carriedOver = overflow1 || overflow2 ? 1 : 0
        }

        var value = UIntX()
        value.parts = values.removingFirst(where: { $0 == 0 })
        if value.parts.isEmpty {
            value.parts = [Element.zero]
        }
        return (value, carriedOver > 0)
    }

    public static func - (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.subtractingReportingOverflow(rhs).partialValue }
    public static func -= (lhs: inout UIntX, rhs: UIntX) { lhs = lhs - rhs }

    // MARK: - Division

    public typealias QuotientAndReminder = (quotient: UIntX<Element>, remainder: UIntX<Element>)

    public func quotientAndRemainder(dividingBy rhs: UIntX<Element>) -> QuotientAndReminder {

        guard self > 0 && rhs > 0 else { return (0, 0) }
        guard rhs > 1 else { return (self, 0) }
        guard self >= rhs else { return (0, self) }

        var quotient: UIntX<Element> = 0
        var remainder: UIntX<Element> = self

        var diffBitWidth = (remainder.bitWidth - remainder.leadingZeroBitCount) - (rhs.bitWidth - rhs.leadingZeroBitCount)
        while diffBitWidth > 0 {
            if remainder >= (rhs << diffBitWidth) {
                remainder -= rhs << diffBitWidth
                quotient += 1 << diffBitWidth
            }
            diffBitWidth -= 1
        }

        if remainder >= rhs {
            remainder -= rhs
            quotient += 1
        }

        return (quotient, remainder)
    }

    public func dividedReportingOverflow(by rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        (quotientAndRemainder(dividingBy: rhs).quotient, false)
    }

    public func remainderReportingOverflow(dividingBy rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        (quotientAndRemainder(dividingBy: rhs).remainder, false)
    }

    public static func / (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.quotientAndRemainder(dividingBy: rhs).quotient }
    public static func /= (lhs: inout UIntX, rhs: UIntX) { lhs = lhs / rhs }

    public static func % (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.quotientAndRemainder(dividingBy: rhs).remainder }
    public static func %= (lhs: inout UIntX, rhs: UIntX) { lhs = lhs % rhs }

    // MARK: - Multiplication

    public func multipliedReportingOverflow(by rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        guard self > 0, rhs > 0 else { return (0, false) }

        let highOperand = Swift.max(self, rhs)
        let lowOperand = Swift.min(self, rhs)

        var value: UIntX = 0
        var lowOperandShifted = lowOperand
        var highOperandShifted = highOperand
        var overflow = false
        while lowOperandShifted != 0 {

            defer {

                lowOperandShifted >>= 1
                let shiftOverflow = highOperandShifted.parts.count >= UIntXConfig.maximumNumberOfWords
                                    && lowOperandShifted != 0
                overflow = overflow || shiftOverflow
                highOperandShifted <<= 1
            }

            guard lowOperandShifted.isOdd else { continue }
            let (partialValue, addOverflow) = value.addingReportingOverflow(highOperandShifted)
            value = partialValue
            overflow = overflow || addOverflow
        }

        return (value, overflow)
    }

    public static func * (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.multipliedReportingOverflow(by: rhs).partialValue }
    public static func *= (lhs: inout UIntX, rhs: UIntX) { lhs = lhs * rhs }
}
