extension UIntX: Equatable {

    public static func == (lhs: UIntX, rhs: UIntX) -> Bool {

        guard lhs.parts.count == rhs.parts.count else { return false }

        return !zip(lhs.parts, rhs.parts).contains(where: { $0 != $1 })
    }
}
