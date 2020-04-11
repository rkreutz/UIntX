import XCTest
@testable import UIntX

final class UIntXRightShiftTests: XCTestCase {

    func testRightShiftUIntX8() {

        let baseValue = 198_640_424_466_246

        for offset in 0 ..< UIntX8.BaseValue.bitWidth {

            let value = baseValue >> offset
            let value8 = UIntX8(value)
            (0 ... value8.bitWidth).forEach {

                XCTAssertEqual(Int(value8 >> $0), value >> $0)
            }
        }
    }

    func testRightShiftUIntX16() {

        let baseValue = 198_640_424_466_246

        for offset in 0 ..< UIntX16.BaseValue.bitWidth {

            let value = baseValue >> offset
            let value16 = UIntX16(value)
            (0 ... value16.bitWidth).forEach {

                XCTAssertEqual(Int(value16 >> $0), value >> $0)
            }
        }
    }

    func testRightShiftUIntX32() {

        let baseValue = 198_640_424_466_246

        for offset in 0 ..< UIntX32.BaseValue.bitWidth {

            let value = baseValue >> offset
            let value32 = UIntX32(value)
            (0 ... value32.bitWidth).forEach {

                XCTAssertEqual(Int(value32 >> $0), value >> $0)
            }
        }
    }

    func testRightShiftUIntX64() {

        let baseValue = 198_640_424_466_246

        for offset in 0 ..< UIntX64.BaseValue.bitWidth {

            let value = baseValue >> offset
            let value64 = UIntX64(value)
            (0 ... value64.bitWidth).forEach {

                XCTAssertEqual(Int(value64 >> $0), value >> $0)
            }
        }
    }

    static var allTests = [
        ("testRightShiftUIntX8", testRightShiftUIntX8),
        ("testRightShiftUIntX16", testRightShiftUIntX16),
        ("testRightShiftUIntX32", testRightShiftUIntX32),
        ("testRightShiftUIntX64", testRightShiftUIntX64)
    ]
}
