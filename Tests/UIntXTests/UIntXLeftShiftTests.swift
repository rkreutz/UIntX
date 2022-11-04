import XCTest
@testable import UIntX

final class UIntXLeftShiftTests: XCTestCase {

    func testLeftShiftUIntX8() {

        let baseValue = 99_320_212_233_123

        for offset in 0 ..< min(UIntX8.BaseValue.bitWidth, baseValue.leadingZeroBitCount) {

            let value = baseValue << offset
            let value8 = UIntX8(value)
            (0 ... (Int.bitWidth - 1) - value8.bitWidth + value8.leadingZeroBitCount).forEach {

                XCTAssertEqual(Int(value8 << $0), value << $0, "\"<< \($0)\"")
            }
        }
    }

    func testLeftShiftUIntX16() {

        let baseValue = 99_320_212_233_123

        let value16 = UIntX16(baseValue)

        XCTAssertEqual(value16 << 16, 6_509_049_428_909_948_928)

        for offset in 0 ..< min(UIntX16.BaseValue.bitWidth, baseValue.leadingZeroBitCount) {

            let value = baseValue << offset
            let value16 = UIntX16(value)
            (0 ... (Int.bitWidth - 1) - value16.bitWidth + value16.leadingZeroBitCount).forEach {

                XCTAssertEqual(Int(value16 << $0), value << $0, "\"<< \($0)\"")
            }
        }
    }

    func testLeftShiftUIntX32() {

        let baseValue = 99_320_212_233_123

        for offset in 0 ..< min(UIntX32.BaseValue.bitWidth, baseValue.leadingZeroBitCount) {

            let value = baseValue << offset
            let value32 = UIntX32(value)
            (0 ... (Int.bitWidth - 1) - value32.bitWidth + value32.leadingZeroBitCount).forEach {

                XCTAssertEqual(Int(value32 << $0), value << $0, "\"<< \($0)\"")
            }
        }
    }

    func testLeftShiftUIntX64() {

        let baseValue = 99_320_212_233_123

        for offset in 0 ..< min(UIntX64.BaseValue.bitWidth, baseValue.leadingZeroBitCount) {

            let value = baseValue << offset
            let value64 = UIntX64(value)
            (0 ... (Int.bitWidth - 1) - value64.bitWidth + value64.leadingZeroBitCount).forEach {

                XCTAssertEqual(Int(value64 << $0), value << $0, "\"<< \($0)\"")
            }
        }
    }

    func testLeftShiftWord() {

        let baseValue: UIntX8 = 0xff

        XCTAssertEqual(baseValue << 8, 0xff00)
    }

    static var allTests = [
        ("testLeftShiftUIntX8", testLeftShiftUIntX8),
        ("testLeftShiftUIntX16", testLeftShiftUIntX16),
        ("testLeftShiftUIntX32", testLeftShiftUIntX32),
        ("testLeftShiftUIntX64", testLeftShiftUIntX64),
        ("testLeftShiftWord", testLeftShiftWord)
    ]
}
