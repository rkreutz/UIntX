# UIntX
![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
[![GitHub tag](https://img.shields.io/github/tag/rkreutz/UIntX.svg)](https://GitHub.com/rkreutz/UIntX/tags/)
![MacOS](https://github.com/rkreutz/UIntX/workflows/MacOS/badge.svg?branch=master&event=push)
![Linux](https://github.com/rkreutz/UIntX/workflows/Linux/badge.svg?branch=master&event=push)

**UIntX** is the unsigned integer to rule them all. It can be used to represent any number, with _virtually_ no size constraints. So you can store unsigned integers of 64-bits (default on most modern computers), 128-bits, 256-bits, 512-bits, 1024-bits, 2048-bits, really whatever size you want may be stored in this one single container.

## Usage

`UIntX` is basically a container for several words of a pre-defined base value, so it is a generic struct that expects a `FixedWidthInteger & UnsignedInteger` as it's specialised base value. Right now in Swift's standard library there are `UInt8`, `UInt16`, `UInt32`, `UInt64` and `UInt` that conform to these protocols, though other structs may be used as well as long as they conform to the specified protocols. There are four type alias provided in the library which goes as follows:
```swift
typealias UIntX8 = UIntX<UInt8>
typealias UIntX16 = UIntX<UInt16>
typealias UIntX32 = UIntX<UInt32>
typealias UIntX64 = UIntX<UInt64>
```
These are there strictly for convenience so `UIntX` is already specialised, you may use them or use the complete declaration of `UIntX` specialising it's base value, e.g. `UIntX<UInt>`.

There are two prefered ways of initialising `UIntX`. The first one is the most straight forward, you just need to provide a `UnsignedInteger` as the initialiser sole argument, like:
```swift
let unsignedInteger: UInt = 123
let uintx = UIntX8(unsignedInteger)
```
`UIntX8` also conforms to `ExpressibleByIntegerLiteral` so you may just initialise it like:
```swift
let uintx: UIntX8 = 123
```

The second preferred way of initialising it is through an array of values, where the **first element of the array is the least significant** number in the array and the **last element in the array is the most significant** number:
```swift
let array: [UInt8] = [0x89, 0x67, 0x45, 0x23, 0x01]
let uintx = UIntX8(ascendingArray: array)
uintx == 0x0123456789 // true
```

Notice that on both initialisers values provided that are higher than the base value can handle will be decomposed into smaller values that the base value can handle, this is all done automatically so you can just throw in any value into `UIntX`. When using the `init(ascending:)` initialiser there is one caveat that you must be aware of, each element of the array will be treated as word of base value magnitude (after decomposing if necessary), here is an example using different base values:
```swift
let array: [UInt64] = [1, 2]
let uintx8 = UIntX8(ascendingArray: array)
let uintx64 = UIntX64(ascendingArray: array)

uintx8 == 0x0201 // this is true, because even if the array has UInt64 values, the values could still be represented by UInt8 (the base value) so each of they will be stored as a single word of magnitude UInt8
uintx64 == 0x00000000000000020000000000000001 // this is true since each element in the provided array will be a word of type UInt64 (base value). By the way, this wouldn't compile since the right side of the operation has 128-bits which can't be generated natively by swift's compiler, so you'd have a compiler error here, you may convert uintx64 to a string and check the string value which will be in hexadecimal 
```

Once you have your `UIntX` you may use it as any other unsigned binary integer value, which means most common operations are available:
```
let binary: UIntX8 = 0b0001_0010
binary << 1     // 0b0010_0100
binary >> 1     // 0b0000_1001
binary & 0b1111 // 0b0000_0010
binary | 0b1111 // 0b0001_1111
binary ^ 0b1111 // 0b0001_1101
~binary         // 0b1110_1101

let value: UIntX8 = 123
value / 4       // 30
value % 4       // 3
value * 4       // 492
value + 4       // 127
value - 4       // 119
value > 4       // true
value < 4       // false
value == 4      // false
value != 4      // true
```

## Technical limit of UIntX

`UIntX` is basically a container for storing words of the base value. To do so we store those words in an array (internally referred as `parts`). Arrays in Swift default to using `Int` indexes which means you can only store as many elements in the array as `Int` itself can handle (which is `Int.max`), since `Int` is a `SignedNumber` one of it's bits (the most significant one) is used to store the sign info, which leaves us with `Int.max` as 2<sup>63</sup> (for a `64-bit` OS). If we use a base value of `UInt64` (64-bit) will mean that each word will be able to store 64 bits, so if we have 1 word we'll have a 64 bits number, if we have 2 words we'll have a 128 bits number, and so on:
```swift
let baseValueBitWidth = 64 // base value number of bits
let indexes = 2^63 // maximum number of words that can be stored
let totalNumberOfBits = baseValueBitWidth * indexes // 64 * 2^63 = 2^6 * 2^63 = 2^69
```
So in the end we'll end up with a number that has **2<sup>69</sup> bits** which means that the maximum number we can reach is **2<sup>(2<sup>69</sup>)</sup>**. That's a huge number, let's try converting it to a base 10 powered number so it's a little bit easier to conceive its value. 

Every time you power 2 to a multiple of 10, the resulting number can be _roughly_ converted to 10 to the power of 3:

2<sup>10</sup> = 1,024   ~   10<sup>3</sup> = 1,000

2<sup>20</sup> = 1,048,576   ~    10<sup>6</sup> = 1,000,000

2<sup>30</sup> = 1,073,741,824   ~    10<sup>9</sup> = 1,000,000,000

So 2<sup>69</sup> could be decomposed as 2<sup>70</sup> * 2<sup>-1</sup> (= 0.5), which in turn can be approximated to: 0.5 * 10<sup>21</sup>

That's the amount of bits we have in that number: roughly _500 billion billion bits_.

Ok, that's a huge amount of bits, now let's convert that to an actual number:

2<sup>(5 * 10<sup>20</sup>)</sup>   ~   10<sup>(5 * 10<sup>19</sup> * 3)</sup> = 10<sup>(1.5 * 10<sup>20</sup>)</sup> = 10<sup>(10<sup>20</sup>)</sup> * 10<sup>(5 * 10<sup>19</sup>)</sup> = 10<sup>(10<sup>20</sup>)</sup> * 10<sup>(10<sup>19</sup>)</sup> * 10<sup>(10<sup>19</sup>)</sup> * 10<sup>(10<sup>19</sup>)</sup> * 10<sup>(10<sup>19</sup>)</sup> * 10<sup>(10<sup>19</sup>)</sup>

10<sup>20</sup> = _100 billion billions_

10<sup>19</sup> = _10 billion billions_

_100 billion billions_ + _10 billion billions_ + _10 billion billions_ + _10 billion billions_ + _10 billion billions_ + _10 billion billions_

That's _150 billion billions_.

That's only the power of the number by the way, so the actual number would be:

**10<sup>_150 billion billions_</sup>**

Hopefully I got the maths right, but anyway it is clear that we can represent a **very massive** number with this struct.

Having said that, **I'm forcefully limiting the number of words that can be stored**, that's being done through:
```swift
UIntXConfig.maximumNumberOfWords = 128
```

I'm doing so as a safety net, since I don't know how a program would behave having to hold such large numbers.

You may change this value at any time, **but do it at your own risk**, I haven't tested `UIntX` using numbers past 8,192 bits (which is already a very large number) so I'd recommend sticking to that limit unless you know what you are doing.

## Installation
### Using Swift Package Manager

Add **UIntX** as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/rkreutz/UIntX", from: "1.0.0")
```

## Help & Feedback
- [Open an issue](https://github.com/rkreutz/UIntX/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/rkreutz/UIntX/pull/new/master) if you want to make some change to `UIntX`.

## Roadmap
- [ ] Init from String
    - [ ] Decimal
    - [ ] Hex
    - [ ] Binary
    - [ ] Different Radix
    - [ ] Base64 string  
- [ ] Codable conformance
- [ ] UInt1 
- [ ] Faster and more efficient operations
    - [ ] Multiplication
    - [ ] Division
- [ ] Any UnsignedInteger & FixedWidthInteger element to be used
