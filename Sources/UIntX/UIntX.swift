import Foundation

public typealias UIntX8 = UIntX<UInt8>
public typealias UIntX16 = UIntX<UInt16>
public typealias UIntX32 = UIntX<UInt32>
public typealias UIntX64 = UIntX<UInt64>

public struct UIntX<Element> where Element: FixedWidthInteger & UnsignedInteger {

    public typealias BaseValue = Element

    var parts: [Element]

    /// Will initialise with the provided value, using the minimum possible number of base elements to represent the value.
    ///
    /// - Parameter value: the provided value
    ///
    /// If the provided value has a larger `bitWidth` than the base element, we'll store an array of the base element that can represent the provided value.
    /// Any `0` elements in the most-significant end will be truncated for the purpose of performance optimisation. For example:
    /// ```
    /// let value: UInt64 = 0x123456
    /// let uintx = UIntX<UInt8>(value) // Will be stored as [0x56, 0x34, 0x12] (from most significant to least).
    ///
    /// ```
    /// UInt64 would have 5 more leading zeroed bytes, but we trim those for improved performance and also so we can compare `UIntX` initialised with
    /// different types the same way, like:
    /// ```
    /// let value1 = UIntX<UInt8>(0x12 as UInt64)
    /// let value2 = UIntX<UInt8>(0x12 as UInt8)
    /// value1 == value2 // true, since any leading 0s are trimed, just the actual non-zero numbers will be compared
    /// ```
    ///
    public init<Value>(_ value: Value) where Value: UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        self.init(withPadding: value)
        parts = parts
            .removingFirst(where: { $0 == 0 })
    }

    private init<Value>(withPadding value: Value) where Value: UnsignedInteger {

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
            .removingOverflow()
            .result
    }

    /// Creates UIntX with the provided array.
    /// - Parameter values: the values in the array from least to most significant.
    ///
    /// The order of the provided array should be from **least significat** to **most significant**,
    /// as follows the example:
    /// ```
    /// let value = UIntX<UInt8>(ascendingArray: [1, 2] as [UInt8])
    /// value // stored as [0x02, 0x01]
    /// value == 0x0201 // true
    /// ```
    /// One must pay attention to the type of values being provided as well, since the `bitWidth` of those values will be taken into account, which might
    /// translate into more words in the base element. For instance if the provided values are of type `UInt16` and the base element is of type `UInt8`,
    /// values in the provided array will be treated as 2 byte values and stored as such, which means:
    /// ```
    /// let value = UIntX<UInt8>(ascendingArray: [1, 2] as [UInt64])
    /// value // stored as [0x02, 0x00, 0x01]
    /// value == 0x020001 // true
    /// ```
    /// Notice that each value in the array has 2 bytes so the array is actually `[0x0002, 0x0001]` and they are stored as such, decomposing those 2 bytes
    /// into words of 1 byte. The most significant number may have its leading `0`s trimmed out for improved performance, but all the remaining values won't
    /// since that would affect the resulting number.
    ///
    /// As for cases where the base element has a larger `bitWidth` than the provided values, the array will be arranged agglomerating enough values to
    /// represent a number from the base element, for example:
    /// ```
    /// let value = UIntX<UInt16>(ascendingArray: [0x01, 0x02, 0x03] as [UInt8])
    /// value // stored as [0x0003, 0x0201]
    /// value == 0x030201
    /// ```
    ///
    /// With all that in mind, pay double attention to the provided value, for instance the following might not be obvious:
    /// ```
    /// let value1 = UIntX<UInt8>(ascendingArray: [0x01, 0x02] as [UInt8]) // Notice that the provided array uses 1 byte per element
    /// let value2 = UIntX<UInt8>(ascendingArray: [0x01, 0x02] as [UInt16]) // Notice that the provided array uses 2 bytes per element
    /// value1 // 0x0201 (2 bytes in total)
    /// value2 // 0x00020001 (4 bytes in total)
    /// value1 == value2 // false
    /// ```
    ///
    public init<Value>(ascendingArray values: [Value]) where Value: FixedWidthInteger & UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        guard Element.bitWidth.isMultiple(of: Value.bitWidth) || Value.bitWidth.isMultiple(of: Element.bitWidth) else {

            fatalError("The provided value must be a multple of the Base value or vice-versa.")
        }

        guard !values.isEmpty else {

            parts = [Element.zero]
            return
        }

        let bitRatio = Element.bitWidth / Value.bitWidth
        if bitRatio == 0 {

            parts = values.reversed()
                .map(UIntX<Element>.init(withPadding:))
                .flatMap(\.parts)
                .removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        } else if values.count <= bitRatio {

            parts = [
                values
                    .map { Element($0) }
                    .enumerated()
                    .reduce(into: Element.zero) { partialResult, enumerated in

                        partialResult += (enumerated.element << (enumerated.offset * Value.bitWidth))
                    }
            ]
        } else {

            parts = values
                .enumerated()
                .reduce(into: [[Value]]()) { partialResult, enumerated in

                    if enumerated.offset % bitRatio == 0 {

                        partialResult.append([enumerated.element])
                    } else {

                        partialResult[partialResult.count - 1].append(enumerated.element)
                    }
                }
                .reversed()
                .map(UIntX<Element>.init(ascendingArray:))
                .flatMap(\.parts)
                .removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        }
    }
}
