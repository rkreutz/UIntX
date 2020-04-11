extension UIntX: Comparable {

    public static func < (lhs: UIntX, rhs: UIntX) -> Bool {

        guard lhs.parts.count == rhs.parts.count else { return lhs.parts.count < rhs.parts.count }

        for (lhs, rhs) in zip(lhs.parts, rhs.parts) {

            guard lhs != rhs else { continue }
            return lhs < rhs
        }

        return false
    }

    public static func > (lhs: UIntX, rhs: UIntX) -> Bool { rhs < lhs }

    public static func <= (lhs: UIntX, rhs: UIntX) -> Bool { lhs == rhs || lhs < rhs }

    public static func >= (lhs: UIntX, rhs: UIntX) -> Bool { lhs == rhs || lhs > rhs }
}
