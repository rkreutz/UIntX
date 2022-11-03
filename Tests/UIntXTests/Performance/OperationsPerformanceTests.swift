import Foundation
import XCTest
@testable import UIntX

final class OperationsPerformanceTests: XCTestCase {
    func testBinaryNot() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut = UIntX8(littleEndianArray: [UInt8](repeating: 0b10101010, count: 131_072))

        measure {
            let value = ~sut
            XCTAssertEqual(value.bitWidth, 1_048_576)
        }
    }

    func testRightShift() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))

        measure {
            let value = sut >> 2
            XCTAssertEqual(value.bitWidth, 1_048_576)
        }
    }

    func testRightShift2() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))

        measure {
            let value = sut >> 1_048_568
            XCTAssertEqual(value.bitWidth, 8)
        }
    }

    func testLeftShift() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = 0xff

        measure {
            let value = sut << 1_048_568
            XCTAssertEqual(value.bitWidth, 1_048_576)
        }
    }

    func testLeftShift2() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_071))

        measure {
            let value = sut << 1
            XCTAssertEqual(value.bitWidth, 1_048_576)
        }
    }

    func testBinaryAnd() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0x0f, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xf0, count: 131_072))

        measure {
            let value = sut & sut2
            XCTAssertEqual(value.bitWidth, 8)
        }
    }

    func testBinaryOr() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0x0f, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xf0, count: 131_072))

        measure {
            let value = sut | sut2
            XCTAssertEqual(value.bitWidth, 1_048_576)
        }
    }

    func testBinaryXor() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))

        measure {
            let value = sut ^ sut2
            XCTAssertEqual(value.bitWidth, 8)
        }
    }

    func testLessThan() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        var sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        sut2.parts[131_071] = 0

        measure {
            XCTAssertEqual(sut2 < sut, true)
        }
    }

    func testLessThanOrEqual() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        var sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        sut2.parts[131_071] = 0

        measure {
            XCTAssertEqual(sut2 <= sut, true)
        }
    }

    func testLessThanOrEqualAlt2() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))

        measure {
            XCTAssertEqual(sut2 <= sut, true)
        }
    }

    func testAddition() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_071))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_071))

        measure {
            let result = sut + sut2
            XCTAssertEqual(result.bitWidth, 1_048_576)
        }
    }

    func testSubtraction() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))

        measure {
            let result = sut - sut2
            XCTAssertEqual(result.bitWidth, 8)
        }
    }

    func testDivision() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        let sut2: UIntX8 = 50

        measure {
            let result = sut / sut2
            XCTAssertEqual(result.bitWidth, 1_048_571)
        }
    }

    func testDivisionAlt2() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_072))
        let sut2: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_071))

        measure {
            let result = sut / sut2
            XCTAssertEqual(result.bitWidth, 16)
        }
    }

    func testDivisionAlt3() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: (0 ..< 1_024).map { _ in UInt8.random(in: 0 ... UInt8.max) })
        let sut2: UIntX8 = UIntX8(littleEndianArray: (0 ..< 1_023).map { _ in UInt8.random(in: 0 ... UInt8.max) })

        measure {
            let result = sut / sut2
            XCTAssertGreaterThan(result, 0)
        }
    }

    func testMultipleDivisions() {
        let sut = UIntX64(littleEndianArray: [UInt64](repeating: UInt64.max, count: 8))
        let divider: UIntX64 = 50

        measure {
            var result = sut
            for _ in 0 ..< 64 {
                result = result / divider
            }
            XCTAssertEqual(result.bitWidth, 192)
        }
    }

    func testMultiplication() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut: UIntX8 = UIntX8(littleEndianArray: [UInt8](repeating: 0xff, count: 131_071))
        let sut2: UIntX8 = 50

        measure {
            let result = sut * sut2
            XCTAssertEqual(result.bitWidth, 1_048_576)
        }
    }

    func testMultipleMultiplications() {
        let sut = UIntX64(littleEndianArray: [UInt64](repeating: UInt64.max, count: 8))
        let multiplier: UIntX64 = 50

        measure {
            var result = sut
            for _ in 0 ..< 40 {
                result = result * multiplier
            }
            XCTAssertEqual(result.bitWidth, 768)
        }
    }
}
