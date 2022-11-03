import Foundation
import XCTest
@testable import UIntX

final class InitilisersPerformanceTests: XCTestCase {

    func testWithHighNumber() {
        measure {
            for _ in 0 ..< 16_384 {
                let sut = UIntX8(UInt64.max)
                XCTAssertEqual(sut.bitWidth, 64)
            }
        }
    }

    func testWithHighNumberHigherBitWidth() {
        measure {
            for _ in 0 ..< 16_384 {
                let sut = UIntX64(UInt32.max)
                XCTAssertEqual(sut.bitWidth, 64)
            }
        }
    }

    func testWithHighNumberSameBitWidth() {
        measure {
            for _ in 0 ..< 16_384 {
                let sut = UIntX64(UInt64.max)
                XCTAssertEqual(sut.bitWidth, 64)
            }
        }
    }

    func testInitWithLowerBitWidth() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let largeUintx = UIntX64(littleEndianArray: [UInt64](repeating: .random(in: 1 ... UInt64.max), count: 16_384))

        measure {
            let sut = UIntX8(largeUintx)
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitWithHigherBitWidth() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let largeUintx = UIntX8(littleEndianArray: [UInt8](repeating: .random(in: 1 ... UInt8.max), count: 131_072))

        measure {
            let sut = UIntX64(largeUintx)
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitWithSameBitWidth() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let largeUintx = UIntX8(littleEndianArray: [UInt8](repeating: .random(in: 1 ... UInt8.max), count: 131_072))

        measure {
            let sut = UIntX8(largeUintx)
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitLittleEndianArray() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX8(littleEndianArray: [UInt8](repeating: .random(in: 1 ... UInt8.max), count: 131_072))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitLittleEndianArrayFromBiggerBitWidthToLower() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX8(littleEndianArray: [UInt64](repeating: UInt64.max, count: 16_384))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitLittleEndianArrayFromLowerBitWidthToBigger() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX64(littleEndianArray: [UInt8](repeating: UInt8.max, count: 131_072))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitBigEndianArray() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX8(bigEndianArray: [UInt8](repeating: .random(in: 1 ... UInt8.max), count: 131_072))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitBigEndianArrayFromBiggerBitWidthToLower() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX8(bigEndianArray: [UInt64](repeating: UInt64.max, count: 16_384))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }

    func testInitBigEndianArrayFromLowerBitWidthToBigger() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            let sut = UIntX64(bigEndianArray: [UInt8](repeating: UInt8.max, count: 131_072))
            XCTAssertEqual(sut.bitWidth, 1_048_576)
        }
    }
}
