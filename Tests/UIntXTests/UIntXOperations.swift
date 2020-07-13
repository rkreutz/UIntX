import XCTest
@testable import UIntX

final class UIntXOperations: XCTestCase {

    func testBinaryNot() {

        XCTAssertEqual(~UIntX8(0b00001010), 0b11110101)
        XCTAssertEqual(
            ~UIntX8(ascendingArray: [0b01010101, 0b00001111, 0b11110000] as [UInt8]),
            0b000011111111000010101010
        )
    }

    func testQuotientAndRemainder() {

        let value: UIntX8 = 4_471_200

        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 9_999_999).quotient, 0)
        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 9_999_999).remainder, 4_471_200)

        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 3).quotient, 1_490_400)
        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 3).remainder, 0)

        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 43).quotient, 103_981)
        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 43).remainder, 17)

        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 7_931).quotient, 563)
        XCTAssertEqual(value.quotientAndRemainder(dividingBy: 7_931).remainder, 6_047)

        XCTAssertEqual(UIntX8(UInt.max - 1).quotientAndRemainder(dividingBy: UIntX8(UInt.max / 2)).quotient, 2)
        XCTAssertEqual(UIntX8(UInt.max - 1).quotientAndRemainder(dividingBy: UIntX8(UInt.max / 2)).remainder, 0)

        XCTAssertEqual(UIntX8(0x7bff).quotientAndRemainder(dividingBy: 0xff).quotient, 0x7c)
        XCTAssertEqual(UIntX8(0x7bff).quotientAndRemainder(dividingBy: 0xff).remainder, 123)

        let largeValue = UIntX8(ascendingArray: [UInt.max, 123])
        XCTAssertEqual(largeValue.quotientAndRemainder(dividingBy: UIntX8(UInt.max)).quotient, 124)
        XCTAssertEqual(largeValue.quotientAndRemainder(dividingBy: UIntX8(UInt.max)).remainder, 123)
    }

    func testAddingWithOverflow() {

        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(0).partialValue, 4_471_200)
        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(0).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(43).partialValue, 4_471_243)
        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(43).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(123_456).partialValue, 4_594_656)
        XCTAssertEqual(UIntX8(4_471_200).addingReportingOverflow(123_456).overflow, false)

        XCTAssertEqual(
            UIntX8(UInt.max).addingReportingOverflow(UIntX8(UInt.max)).partialValue,
            UIntX8(ascendingArray: [UInt.max - 1, 1])
        )
        XCTAssertEqual(UIntX8(UInt.max).addingReportingOverflow(UIntX8(UInt.max)).overflow, false)
    }

    func testSubtractingWithOverflow() {

        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(0).partialValue, 4_471_200)
        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(0).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(43).partialValue, 4_471_157)
        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(43).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(123_456).partialValue, 4_347_744)
        XCTAssertEqual(UIntX8(4_471_200).subtractingReportingOverflow(123_456).overflow, false)

        XCTAssertEqual(UIntX8(UInt.max).subtractingReportingOverflow(UIntX8(UInt.max)).partialValue, 0)
        XCTAssertEqual(UIntX8(UInt.max).subtractingReportingOverflow(UIntX8(UInt.max)).overflow, false)

        XCTAssertEqual(
            UIntX8(ascendingArray: [UInt.max, 567_890])
                .subtractingReportingOverflow(UIntX8(UInt.max))
                .partialValue,
            UIntX8(ascendingArray: [0, 567_890] as [UInt])
        )

        XCTAssertEqual(
            UIntX8(ascendingArray: [UInt.max, 567_890]).subtractingReportingOverflow(UIntX8(UInt.max)).overflow,
            false
        )

        XCTAssertEqual(
            UIntX8(ascendingArray: [UInt.max, 567_890])
                .subtractingReportingOverflow(UIntX8(ascendingArray: [UInt.max, 567_890]))
                .partialValue,
            0
        )

        XCTAssertEqual(
            UIntX8(ascendingArray: [UInt.max, 567_890])
                .subtractingReportingOverflow(UIntX8(ascendingArray: [UInt.max, 567_890]))
                .overflow,
            false
        )

        XCTAssertEqual(
            UIntX8(ascendingArray: [UInt.max, 567_890])
                .subtractingReportingOverflow(UIntX8(ascendingArray: [UInt.max, 567_891]))
                .overflow,
            true
        )

        XCTAssertEqual(UIntX8(23).subtractingReportingOverflow(45).partialValue, 0b11101010)
        XCTAssertEqual(UIntX8(23).subtractingReportingOverflow(45).overflow, true)

        XCTAssertEqual(UIntX8(23).subtractingReportingOverflow(267).partialValue, 0b1111111100001100)
        XCTAssertEqual(UIntX8(23).subtractingReportingOverflow(267).overflow, true)
    }

    func testMultiplyingWithOverflow() {

        XCTAssertEqual(UIntX8(23).multipliedReportingOverflow(by: 45).partialValue, 1_035)
        XCTAssertEqual(UIntX8(23).multipliedReportingOverflow(by: 45).overflow, false)
        
        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 0).partialValue, 0)
        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 0).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 1).partialValue, 4_471_200)
        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 1).overflow, false)

        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 43).partialValue, 192_261_600)
        XCTAssertEqual(UIntX8(4_471_200).multipliedReportingOverflow(by: 43).overflow, false)

        XCTAssertEqual(UIntX8(0xffff).multipliedReportingOverflow(by: 0xffff).partialValue, 0xfffe0001)
        XCTAssertEqual(UIntX8(0xffff).multipliedReportingOverflow(by: 0xffff).overflow, false)

        XCTAssertEqual(UIntX8(0xffffff).multipliedReportingOverflow(by: 0xffffff).partialValue, 0xfffffe000001)
        XCTAssertEqual(UIntX8(0xffffff).multipliedReportingOverflow(by: 0xffffff).overflow, false)

        XCTAssertEqual(
            UIntX8(0xffffffff).multipliedReportingOverflow(by: 0xffffffff).partialValue,
            0xfffffffe00000001
        )
        XCTAssertEqual(UIntX8(0xffffffff).multipliedReportingOverflow(by: 0xffffffff).overflow, false)
    }

    func testBinaryAnd() {

        XCTAssertEqual(UIntX8(0x123456789) & UIntX8(0x987654321), 0x103454301)
        XCTAssertEqual(UIntX8(0) & UIntX8(0), 0)
        XCTAssertEqual(UIntX8(0x123456789) & UIntX8(0), 0)
    }

    func testBinaryOr() {

        XCTAssertEqual(UIntX8(0x123456789) | UIntX8(0x987654321), 0x9a76567a9)
        XCTAssertEqual(UIntX8(0) | UIntX8(0), 0)
        XCTAssertEqual(UIntX8(0x123456789) | UIntX8(0), 0x123456789)
    }

    func testBinaryXor() {

        XCTAssertEqual(UIntX8(0x123456789) ^ UIntX8(0x987654321), 0x8a42024a8)
        XCTAssertEqual(UIntX8(0) ^ UIntX8(0), 0)
        XCTAssertEqual(UIntX8(0x123456789) ^ UIntX8(0), 0x123456789)
    }

    static let allTests = [
        ("testBinaryNot", testBinaryNot),
        ("testQuotientAndRemainder", testQuotientAndRemainder),
        ("testAddingWithOverflow", testAddingWithOverflow),
        ("testSubtractingWithOverflow", testSubtractingWithOverflow),
        ("testMultiplyingWithOverflow", testMultiplyingWithOverflow),
        ("testBinaryAnd", testBinaryAnd),
        ("testBinaryOr", testBinaryOr),
        ("testBinaryXor", testBinaryXor)
    ]
}
