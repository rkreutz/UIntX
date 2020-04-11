extension UIntX: UnsignedInteger {

    public static var zero: UIntX { UIntX(Element.zero) }
    public static var max: UIntX { UIntX(ascendingArray: (0 ... Int.max).map { _ in Element.max }) }
    public static var min: UIntX { UIntX(Element.min) }

    public var isEven: Bool { ((parts.last ?? 0) & 1) == 0 }
    public var isOdd: Bool { ((parts.last ?? 0) & 1) == 1 }
}
