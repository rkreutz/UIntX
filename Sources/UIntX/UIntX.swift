import Foundation

public typealias UIntX8 = UIntX<UInt8>
public typealias UIntX16 = UIntX<UInt16>
public typealias UIntX32 = UIntX<UInt32>
public typealias UIntX64 = UIntX<UInt64>

public struct UIntX<Element> where Element: FixedWidthInteger & UnsignedInteger {

    public typealias BaseValue = Element

    var parts: [Element]

    /// Efficient initialiser for same type `UIntX` values
    /// - Parameter value: the `UIntX` value to copy the parts from
    public init(_ value: Self) {
        self.parts = value.parts
    }

    /// Efficient initialiser for `UIntX`s with different `Element` type
    ///
    /// `Element.bitWidth` of the provided `UIntX` value should be a multiple or a factor of `Element.bitWidth` of the `UIntX` being created.
    ///
    /// - When converting a `UIntX` with the same `Element.bitWidth` as the provided `UIntX`, this will simply map the underlying words to the new `Element` type.
    /// - When converting a `UIntX` with a bigger `Element.bitWidth` as the provided `UIntX`, this will first align the words in the provided `UIntX` so it matches the words
    /// we are creating and then will move the each word of the provided `UIntX` into the appropriate bitwise position. E.g:
    /// ```
    /// let value = UIntX<UInt8>(0x123456) // this will have 3 words (0x12, 0x34, 0x56)
    /// let newValue = UIntX<UInt16>(value) // this will have 2 words (0x0012, 0x3456), with bit equivalence to the previous value
    /// ```
    /// - When converting a `UIntX` with a smaller `Element.bitWidth` as the provided `UIntX`, this will move relevant bits to their corresponding word in the new `UIntX` and
    /// removing any leading words that are `0`, e.g:
    /// ```
    /// let value = UIntX<UInt16>(0x123456) // this will have 2 words (0x0012, 0x3456)
    /// let newValue = UIntX<UInt8>(value)  // this will have 3 words (0x12, 0x34, 0x56), with bit equivalence to the previous value but with the leading 0x00 trimmed.
    /// ```
    public init<Value: FixedWidthInteger & UnsignedInteger>(_ uintx: UIntX<Value>) {
        if Value.bitWidth == Element.bitWidth {
            self.parts = uintx.parts.map(Element.init(_:))
        } else if Value.bitWidth < Element.bitWidth {
            precondition(
                Element.bitWidth.isMultiple(of: Value.bitWidth),
                "\(Element.self) bit arrangement is not aligned to \(Value.self)"
            )

            let bitRatio = Element.bitWidth / Value.bitWidth
            let partsCount = Int(ceil(Double(uintx.parts.count) / Double(bitRatio)))
            let oldAlignedParts = uintx.parts.align(to: bitRatio, paddingElement: .zero)
            self.parts = [Element](repeating: .zero, count: partsCount)
            for oldIndex in (0 ..< oldAlignedParts.count).reversed() {
                let newIndex = oldIndex / bitRatio
                let bitShift = (bitRatio - (oldIndex % bitRatio) - 1) * Value.bitWidth
                self.parts[newIndex] |= Element(oldAlignedParts[oldIndex]) << bitShift
            }
            self.parts = self.parts.removingFirst(where: { $0 == .zero })
        } else {
            precondition(
                Value.bitWidth.isMultiple(of: Element.bitWidth),
                "\(Value.self) bit arrangement is not aligned to \(Element.self)"
            )

            let bitRatio = Value.bitWidth / Element.bitWidth
            let partsCount = uintx.parts.count * bitRatio
            self.parts = [Element](repeating: .zero, count: partsCount)
            for newIndex in (0 ..< partsCount).reversed() {
                let oldIndex = newIndex / bitRatio
                let bitShift = (bitRatio - (newIndex % bitRatio) - 1) * Element.bitWidth
                let mask = Value(Element.max)
                self.parts[newIndex] = Element((uintx.parts[oldIndex] >> bitShift) & mask)
            }
            self.parts = self.parts.removingFirst(where: { $0 == .zero })
        }
    }

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
    public init<Value: FixedWidthInteger & UnsignedInteger>(_ value: Value)  {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        self.init(withPadding: value)
        parts = parts.removingFirst(where: { $0 == .zero })
    }

    /// Creates UIntX with the provided array.
    /// - Parameter values: the values in the array from least to most significant.
    ///
    /// The order of the provided array should be from **least significat** to **most significant**,
    /// as follows the example:
    /// ```
    /// let value = UIntX<UInt8>(littleEndianArray: [1, 2] as [UInt8])
    /// value // stored as [0x02, 0x01]
    /// value == 0x0201 // true
    /// ```
    /// One must pay attention to the type of values being provided as well, since the `bitWidth` of those values will be taken into account, which might
    /// translate into more words in the base element. For instance if the provided values are of type `UInt16` and the base element is of type `UInt8`,
    /// values in the provided array will be treated as 2 byte values and stored as such, which means:
    /// ```
    /// let value = UIntX<UInt8>(littleEndianArray: [1, 2] as [UInt64])
    /// value // stored as [0x02, 0x00, 0x01]
    /// value == 0x020001 // true
    /// ```
    /// Notice that each value in the array has 2 bytes so the array is actually `[0x0002, 0x0001]` and they are stored as such, decomposing those 2 bytes
    /// into words of 1 byte. The most significant number may have its leading `0`s trimmed out for improved performance, but all the remaining values won't
    /// since that would affect the resulting number.
    ///
    /// As for cases where the base element has a larger `bitWidth` than the provided values, the array will be arranged packing enough values to
    /// represent a number from the base element, for example:
    /// ```
    /// let value = UIntX<UInt16>(littleEndianArray: [0x01, 0x02, 0x03] as [UInt8])
    /// value // stored as [0x0003, 0x0201]
    /// value == 0x030201
    /// ```
    ///
    /// With all that in mind, pay double attention to the provided value, for instance the following might not be obvious:
    /// ```
    /// let value1 = UIntX<UInt8>(littleEndianArray: [0x01, 0x02] as [UInt8]) // Notice that the provided array uses 1 byte per element
    /// let value2 = UIntX<UInt8>(littleEndianArray: [0x01, 0x02] as [UInt16]) // Notice that the provided array uses 2 bytes per element
    /// value1 // 0x0201 (2 bytes in total)
    /// value2 // 0x00020001 (4 bytes in total)
    /// value1 == value2 // false
    /// ```
    ///
    public init<Value>(littleEndianArray values: [Value]) where Value: FixedWidthInteger & UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        precondition(
            Element.bitWidth.isMultiple(of: Value.bitWidth) || Value.bitWidth.isMultiple(of: Element.bitWidth),
            "The provided value must be a multple of the Base value or vice-versa."
        )

        guard !values.isEmpty else {

            parts = [Element.zero]
            return
        }

        if Element.bitWidth == Value.bitWidth {
            self.parts = [Element](repeating: .zero, count: values.count)
            for index in 0 ..< values.count {
                self.parts[values.count - index - 1] = Element(values[index])
            }
            self.parts = self.parts.removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        } else if Element.bitWidth < Value.bitWidth {
            self.parts = values.reversed()
                .flatMap { UIntX<Element>(withPadding: $0).parts }
                .removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        } else {
            let bitRatio = Element.bitWidth / Value.bitWidth
            if values.count <= bitRatio {
                self.parts = [
                    values.enumerated().reduce(into: Element.zero) { partialResult, enumerated in
                        let (offset, element) = enumerated
                        partialResult += (Element(element) << (offset * Value.bitWidth))
                    }
                ]
            } else {
                let partsCount = Int(ceil(Double(values.count) / Double(bitRatio)))
                let alignedValues = values.reversed().align(to: bitRatio, paddingElement: .zero)
                self.parts = [Element](repeating: .zero, count: partsCount)
                for oldIndex in (0 ..< alignedValues.count).reversed() {
                    let newIndex = oldIndex / bitRatio
                    let bitShift = (bitRatio - (oldIndex % bitRatio) - 1) * Value.bitWidth
                    self.parts[newIndex] |= Element(alignedValues[oldIndex]) << bitShift
                }
                self.parts = self.parts
                    .removingFirst(where: { $0 == .zero })
                    .removingOverflow()
                    .result
            }
        }
    }

    /// Creates UIntX with the provided array.
    /// - Parameter values: the values in the array from most to least significant.
    ///
    /// The order of the provided array should be from **most significat** to **least significant**,
    /// as follows the example:
    /// ```
    /// let value = UIntX<UInt8>(bigEndianArray: [2, 1] as [UInt8])
    /// value // stored as [0x02, 0x01]
    /// value == 0x0201 // true
    /// ```
    /// One must pay attention to the type of values being provided as well, since the `bitWidth` of those values will be taken into account, which might
    /// translate into more words in the base element. For instance if the provided values are of type `UInt16` and the base element is of type `UInt8`,
    /// values in the provided array will be treated as 2 byte values and stored as such, which means:
    /// ```
    /// let value = UIntX<UInt8>(bigEndianArray: [2, 1] as [UInt64])
    /// value // stored as [0x02, 0x00, 0x01]
    /// value == 0x020001 // true
    /// ```
    /// Notice that each value in the array has 2 bytes so the array is actually `[0x0002, 0x0001]` and they are stored as such, decomposing those 2 bytes
    /// into words of 1 byte. The most significant number may have its leading `0`s trimmed out for improved performance, but all the remaining values won't
    /// since that would affect the resulting number.
    ///
    /// As for cases where the base element has a larger `bitWidth` than the provided values, the array will be arranged packing enough values to
    /// represent a number from the base element, for example:
    /// ```
    /// let value = UIntX<UInt16>(bigEndianArray: [0x03, 0x02, 0x01] as [UInt8])
    /// value // stored as [0x0003, 0x0201]
    /// value == 0x030201
    /// ```
    ///
    /// With all that in mind, pay double attention to the provided value, for instance the following might not be obvious:
    /// ```
    /// let value1 = UIntX<UInt8>(bigEndianArray: [0x02, 0x01] as [UInt8]) // Notice that the provided array uses 1 byte per element
    /// let value2 = UIntX<UInt8>(bigEndianArray: [0x02, 0x01] as [UInt16]) // Notice that the provided array uses 2 bytes per element
    /// value1 // 0x0201 (2 bytes in total)
    /// value2 // 0x00020001 (4 bytes in total)
    /// value1 == value2 // false
    /// ```
    ///
    public init<Value>(bigEndianArray values: [Value]) where Value: FixedWidthInteger & UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        precondition(
            Element.bitWidth.isMultiple(of: Value.bitWidth) || Value.bitWidth.isMultiple(of: Element.bitWidth),
            "The provided value must be a multple of the Base value or vice-versa."
        )

        guard !values.isEmpty else {

            parts = [Element.zero]
            return
        }

        if Element.bitWidth == Value.bitWidth {
            self.parts = values.map(Element.init(_:))
                .removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        } else if Element.bitWidth < Value.bitWidth {
            self.parts = values.flatMap { UIntX<Element>(withPadding: $0).parts }
                .removingFirst(where: { $0 == 0 })
                .removingOverflow()
                .result
        } else {
            let bitRatio = Element.bitWidth / Value.bitWidth
            if values.count <= bitRatio {
                self.parts = [
                    values.enumerated().reduce(into: Element.zero) { partialResult, enumerated in
                        let (offset, element) = enumerated
                        partialResult += (Element(element) << ((values.count - 1 - offset) * Value.bitWidth))
                    }
                ]
            } else {
                let partsCount = Int(ceil(Double(values.count) / Double(bitRatio)))
                let alignedValues = values.align(to: bitRatio, paddingElement: .zero)
                self.parts = [Element](repeating: .zero, count: partsCount)
                for oldIndex in 0 ..< alignedValues.count {
                    let newIndex = oldIndex / bitRatio
                    let bitShift = (bitRatio - (oldIndex % bitRatio) - 1) * Value.bitWidth
                    self.parts[newIndex] |= Element(alignedValues[oldIndex]) << bitShift
                }
                self.parts = self.parts
                    .removingFirst(where: { $0 == .zero })
                    .removingOverflow()
                    .result
            }
        }
    }

    private init<Value>(withPadding value: Value) where Value: FixedWidthInteger & UnsignedInteger {

        defer { if parts.isEmpty { parts = [Element.zero] } }

        guard Element.bitWidth < value.bitWidth else {

            parts = [Element(value)]
            return
        }

        let bitRatio = Int(ceil(Double(value.bitWidth) / Double(Element.bitWidth)))
        precondition(
            bitRatio <= UIntXConfig.maximumNumberOfWords,
            "Value '\(value)' is too big to be represented in \(UIntXConfig.maximumNumberOfWords) words of \(Element.self)"
        )
        
        let mask = Value(Element.max)
        parts = [Element](repeating: .zero, count: bitRatio)
        for index in 0 ..< bitRatio {
            let bitMask = index * Element.bitWidth
            let maskedValue = (value >> bitMask) & mask
            parts[bitRatio - index - 1] = Element(maskedValue)
        }
        parts = parts.removingOverflow().result
    }
}
