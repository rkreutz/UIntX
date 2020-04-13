extension UIntX: Numeric {

    public var magnitude: UIntX { self }

    public init?<Value>(exactly source: Value) where Value: BinaryInteger {

        self.init(ascendingArray: Array(source.words))
    }

    // MARK: - Addition

    public func addingReportingOverflow(_ rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        var values = [Element]()
        var carriedOver: Element = 0

        for index in 0 ..< Swift.max(parts.count, rhs.parts.count) {

            let lhsPart = parts.reversed().at(index: index) ?? 0
            let rhsPart = rhs.parts.reversed().at(index: index) ?? 0
            let (result1, overflow1) = lhsPart.addingReportingOverflow(rhsPart)
            let (result2, overflow2) = result1.addingReportingOverflow(carriedOver)

            values.append(result2)
            carriedOver = overflow1 || overflow2 ? 1 : 0
        }

        if carriedOver > 0 { values.append(carriedOver) }

        let (limitedValues, overflow) = values.removingOverflow()
        return (UIntX(ascendingArray: limitedValues), overflow)
    }

    public static func + (lhs: UIntX, rhs: UIntX) -> UIntX { lhs.addingReportingOverflow(rhs).partialValue }
    public static func += (lhs: inout UIntX, rhs: UIntX) { lhs = lhs + rhs }

    // MARK: - Subtraction

    public func subtractingReportingOverflow(_ rhs: UIntX) -> (partialValue: UIntX, overflow: Bool) {

        var values = [Element]()
        var carriedOver: Element = 0

        for index in 0 ..< Swift.max(parts.count, rhs.parts.count) {

            let lhsPart = parts.reversed().at(index: index) ?? 0
            let rhsPart = rhs.parts.reversed().at(index: index) ?? 0
            let (result1, overflow1) = lhsPart.subtractingReportingOverflow(rhsPart)
            let (result2, overflow2) = result1.subtractingReportingOverflow(carriedOver)

            values.append(result2)
            carriedOver = overflow1 || overflow2 ? 1 : 0
        }

        let (limitedValues, overflow) = values.removingOverflow()
        return (UIntX(ascendingArray: limitedValues), carriedOver > 0 || overflow)
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
        var partial: UIntX<Element> = 1
        var chunk: UIntX<Element> = rhs
        var trail: [(UIntX<Element>, UIntX<Element>)] = [(1, rhs)]

        while remainder - chunk >= chunk {

            chunk = chunk << 1
            partial = partial << 1
            trail.append((partial, chunk))
        }

        for (partial, chunk) in trail.reversed() {

            guard remainder >= chunk else { continue }

            remainder -= chunk
            quotient += partial
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
