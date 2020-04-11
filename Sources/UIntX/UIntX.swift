import Foundation

public typealias UIntX8 = UIntX<UInt8>
public typealias UIntX16 = UIntX<UInt16>
public typealias UIntX32 = UIntX<UInt32>
public typealias UIntX64 = UIntX<UInt64>

public struct UIntX<Element> where Element: FixedWidthInteger & UnsignedInteger {

    public typealias BaseValue = Element

    var parts: [Element]

    public init<Value>(_ value: Value) where Value: UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        guard Element.bitWidth < value.bitWidth else {

            parts = [Element(value)]
            return
        }

        let bitRatio = Int(ceil(Double(value.bitWidth) / Double(Element.bitWidth)))
        let mask = Value(Element.max)
        parts = (0 ..< bitRatio)
            .map { $0 * Element.bitWidth }
            .map { (value & (mask << $0)) >> $0 }
            .map { Element($0) }
            .reversed()
            .removingFirst(where: { $0 == 0 })
            .removingOverflow()
            .result
    }

    /// Creates UIntX with the provided array.
    /// - Parameter values: the values in the array from least to most significant.
    ///
    /// The order of the provided array should be from **least significat** to **most significant**,
    /// as follows the example:
    ///```
    ///let value = UIntX<UInt8>(ascendingArray: [1, 2] as [UInt])
    ///value // stored as [0x02, 0x01]
    ///value == 0x0201 // true
    ///```
    ///Each element in the array provided will be treated as an element of the base value and decomposed if necessary,
    ///for instance if the element has more bits than the base value can handle that element will be transformed
    ///into `n` base value elements that can actually represent that value, as follows the example:
    ///```
    ///let value = UIntX<UInt8>(ascendingArray: [0x1234, 0x1, 0x2] as [UInt])
    ///value // stored as [0x02, 0x01, 0x12, 0x34]
    ///value == 0x02011234 // true
    ///let value2 = UIntX<UInt16>(ascendingArray: [1, 2] as [UInt8])
    ///value // stored as [0x0002, 0x0001]
    ///value2 == 0x00020001 // true
    ///```
    ///
    public init<Value>(ascendingArray values: [Value]) where Value: FixedWidthInteger & UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        guard Element.bitWidth.isMultiple(of: Value.bitWidth) || Value.bitWidth.isMultiple(of: Element.bitWidth) else {

            fatalError("UIntX is not ready to deal with values different than UInt1, UInt8, UInt16, UInt32 or UInt64")
        }

        guard !values.isEmpty else {

            parts = [Element.zero]
            return
        }

        parts = values.reversed()
            .map(UIntX<Element>.init)
            .flatMap(\.parts)
            .removingFirst(where: { $0 == 0 })
            .removingOverflow()
            .result
    }
}
