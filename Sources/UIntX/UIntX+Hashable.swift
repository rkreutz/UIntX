extension UIntX: Hashable {

    public func hash(into hasher: inout Hasher) {

        parts.forEach { hasher.combine($0) }
    }
}
