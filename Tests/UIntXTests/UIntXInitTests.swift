import XCTest
@testable import UIntX

final class UIntXInitTests: XCTestCase {

    func testUIntX8Initialization() {

        let value1 = UIntX<UInt8>(littleEndianArray: [0x12, 0x34, 0x56] as [UInt8])
        XCTAssertEqual(value1.parts, [0x56, 0x34, 0x12])
        XCTAssertEqual(value1, 0x563412)

        // Since UInt16 has 2 bytes, every element in the array must be considered a 2 bytes number, even if the
        // most significant byte is zero
        let value2 = UIntX<UInt8>(littleEndianArray: [0x12, 0x34, 0x56] as [UInt16])
        // Notice the 0 padding the 2 byte numbers. The first (most significant) might have its 0 padding stripped for improved performance.
        XCTAssertEqual(value2.parts, [0x56, 0x00, 0x34, 0x00, 0x12])
        XCTAssertEqual(value2, 0x5600340012)

        // Same for larger magnitude numbers
        let value3 = UIntX<UInt8>(littleEndianArray: [0x12, 0x34] as [UInt64])
        XCTAssertEqual(value3.parts, [0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value3.description, "0x340000000000000012")
    }

    func testUIntX8BigEndianInitialization() {

        let value1 = UIntX<UInt8>(bigEndianArray: [0x56, 0x34, 0x12] as [UInt8])
        XCTAssertEqual(value1.parts, [0x56, 0x34, 0x12])
        XCTAssertEqual(value1, 0x563412)

        // Since UInt16 has 2 bytes, every element in the array must be considered a 2 bytes number, even if the
        // most significant byte is zero
        let value2 = UIntX<UInt8>(bigEndianArray: [0x56, 0x34, 0x12] as [UInt16])
        // Notice the 0 padding the 2 byte numbers. The first (most significant) might have its 0 padding stripped for improved performance.
        XCTAssertEqual(value2.parts, [0x56, 0x00, 0x34, 0x00, 0x12])
        XCTAssertEqual(value2, 0x5600340012)

        // Same for larger magnitude numbers
        let value3 = UIntX<UInt8>(bigEndianArray: [0x34, 0x12] as [UInt64])
        XCTAssertEqual(value3.parts, [0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value3.description, "0x340000000000000012")
    }

    func testUIntX16Initialization() {

        let value1 = UIntX<UInt16>(littleEndianArray: [0x1234, 0x5678] as [UInt16])
        XCTAssertEqual(value1.parts, [0x5678, 0x1234])
        XCTAssertEqual(value1, 0x56781234)

        let value2 = UIntX<UInt16>(littleEndianArray: [0x12, 0x34] as [UInt16])
        XCTAssertEqual(value2.parts, [0x34, 0x0012])
        XCTAssertEqual(value2, 0x340012)

        // Since UInt8 has 1 byte, we should agglomerate enough UInt8 to create a UInt16 (2 bytes) and set each part accordingly
        let value3 = UIntX<UInt16>(littleEndianArray: [0x12, 0x34, 0x56, 0x78] as [UInt8])
        XCTAssertEqual(value3.parts, [0x7856, 0x3412])
        XCTAssertEqual(value3, 0x78563412)

        // Since UInt32 has 4 bytes, every element in the array must be considered a 4 bytes number, even if the
        // most significant byte is zero
        let value4 = UIntX<UInt16>(littleEndianArray: [0x1234, 0x5678] as [UInt32])
        // Notice the 0 padding the 4 byte numbers. The first (most significant) might have its 0 padding stripped for improved performance.
        XCTAssertEqual(value4.parts, [0x5678, 0x0000, 0x1234])
        XCTAssertEqual(value4, 0x567800001234)

        // Same for larger magnitude numbers
        let value5 = UIntX<UInt16>(littleEndianArray: [0x1234, 0x5678] as [UInt64])
        XCTAssertEqual(value5.parts, [0x5678, 0x0000, 0x0000, 0x0000, 0x1234])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value5.description, "0x56780000000000001234")
    }

    func testUIntX16BigEndianInitialization() {

        let value1 = UIntX<UInt16>(bigEndianArray: [0x5678, 0x1234] as [UInt16])
        XCTAssertEqual(value1.parts, [0x5678, 0x1234])
        XCTAssertEqual(value1, 0x56781234)

        let value2 = UIntX<UInt16>(bigEndianArray: [0x34, 0x12] as [UInt16])
        XCTAssertEqual(value2.parts, [0x34, 0x0012])
        XCTAssertEqual(value2, 0x340012)

        // Since UInt8 has 1 byte, we should agglomerate enough UInt8 to create a UInt16 (2 bytes) and set each part accordingly
        let value3 = UIntX<UInt16>(bigEndianArray: [0x78, 0x56, 0x34, 0x12] as [UInt8])
        XCTAssertEqual(value3.parts, [0x7856, 0x3412])
        XCTAssertEqual(value3, 0x78563412)

        // Since UInt32 has 4 bytes, every element in the array must be considered a 4 bytes number, even if the
        // most significant byte is zero
        let value4 = UIntX<UInt16>(bigEndianArray: [0x5678, 0x1234] as [UInt32])
        // Notice the 0 padding the 4 byte numbers. The first (most significant) might have its 0 padding stripped for improved performance.
        XCTAssertEqual(value4.parts, [0x5678, 0x0000, 0x1234])
        XCTAssertEqual(value4, 0x567800001234)

        // Same for larger magnitude numbers
        let value5 = UIntX<UInt16>(bigEndianArray: [0x5678, 0x1234] as [UInt64])
        XCTAssertEqual(value5.parts, [0x5678, 0x0000, 0x0000, 0x0000, 0x1234])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value5.description, "0x56780000000000001234")
    }

    func testUIntX64Initialization() {

        let value1 = UIntX<UInt64>(littleEndianArray: [0x1234567890123456, 0x7890123456789012] as [UInt64])
        XCTAssertEqual(value1.parts, [0x7890123456789012, 0x1234567890123456])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value1.description, "0x78901234567890121234567890123456")

        let value2 = UIntX<UInt64>(littleEndianArray: [0x12, 0x34] as [UInt64])
        XCTAssertEqual(value2.parts, [0x34, 0x0000000000000012])
        XCTAssertEqual(value2.description, "0x00000000000000340000000000000012")

        // Since UInt8 has 1 byte, we should agglomerate enough UInt8 to create a UInt64 (8 bytes) and set each part accordingly
        let value3 = UIntX<UInt64>(littleEndianArray: [0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x56, 0x78] as [UInt8])
        XCTAssertEqual(value3.parts, [0x78, 0x5634129078563412])
        XCTAssertEqual(value3.description, "0x00000000000000785634129078563412")

        // Same for UInt16
        let value4 = UIntX<UInt64>(littleEndianArray: [0x1234, 0x5678, 0x9012, 0x3456, 0x78] as [UInt16])
        XCTAssertEqual(value4.parts, [0x78, 0x3456901256781234])
        XCTAssertEqual(value4.description, "0x00000000000000783456901256781234")

        // Same for UInt32
        let value5 = UIntX<UInt64>(littleEndianArray: [0x12345678, 0x90123456, 0x78] as [UInt32])
        XCTAssertEqual(value5.parts, [0x78, 0x9012345612345678])
        XCTAssertEqual(value5.description, "0x00000000000000789012345612345678")
    }

    func testUIntX64BigEndianInitialization() {

        let value1 = UIntX<UInt64>(bigEndianArray: [0x7890123456789012, 0x1234567890123456] as [UInt64])
        XCTAssertEqual(value1.parts, [0x7890123456789012, 0x1234567890123456])
        // Since Swift can't represent natively a number with more than 8 bytes we have to use the description to compare values
        XCTAssertEqual(value1.description, "0x78901234567890121234567890123456")

        let value2 = UIntX<UInt64>(bigEndianArray: [0x34, 0x12] as [UInt64])
        XCTAssertEqual(value2.parts, [0x34, 0x0000000000000012])
        XCTAssertEqual(value2.description, "0x00000000000000340000000000000012")

        // Since UInt8 has 1 byte, we should agglomerate enough UInt8 to create a UInt64 (8 bytes) and set each part accordingly
        let value3 = UIntX<UInt64>(bigEndianArray: [0x78, 0x56, 0x34, 0x12, 0x90, 0x78, 0x56, 0x34 ,0x12] as [UInt8])
        XCTAssertEqual(value3.parts, [0x78, 0x5634129078563412])
        XCTAssertEqual(value3.description, "0x00000000000000785634129078563412")

        // Same for UInt16
        let value4 = UIntX<UInt64>(bigEndianArray: [0x78, 0x3456, 0x9012, 0x5678, 0x1234] as [UInt16])
        XCTAssertEqual(value4.parts, [0x78, 0x3456901256781234])
        XCTAssertEqual(value4.description, "0x00000000000000783456901256781234")

        // Same for UInt32
        let value5 = UIntX<UInt64>(bigEndianArray: [0x78, 0x90123456, 0x12345678] as [UInt32])
        XCTAssertEqual(value5.parts, [0x78, 0x9012345612345678])
        XCTAssertEqual(value5.description, "0x00000000000000789012345612345678")
    }

    func testUIntX64ToUIntX8Initialization() {

        let value1 = UIntX<UInt64>(littleEndianArray: [0x1234567890123456, 0x7890123456789012] as [UInt64])
        let value2 = UIntX<UInt8>(value1)
        XCTAssertEqual(value2.description, "0x78901234567890121234567890123456")

        let value3 = UIntX<UInt64>(littleEndianArray: [0x12, 0x34] as [UInt64])
        let value4 = UIntX<UInt8>(value3)
        XCTAssertEqual(value4.description, "0x340000000000000012")
    }

    func testUIntX8ToUIntX64Initialization() {

        let value1 = UIntX<UInt8>(littleEndianArray: [0x12, 0x34] as [UInt64])
        let value2 = UIntX<UInt64>(value1)
        XCTAssertEqual(value2.description, "0x00000000000000340000000000000012")

    }

    func testUIntX64ToUIntX64Initialization() {

        let value1 = UIntX<UInt64>(littleEndianArray: [0x1234567890123456, 0x7890123456789012] as [UInt64])
        let value2 = UIntX<UInt64>(value1)
        XCTAssertEqual(value1, value2)
        XCTAssertEqual(value2.description, "0x78901234567890121234567890123456")
    }

    static let allTests = [
        ("testUIntX8Initialization", testUIntX8Initialization),
        ("testUIntX8BigEndianInitialization", testUIntX8BigEndianInitialization),
        ("testUIntX16Initialization", testUIntX16Initialization),
        ("testUIntX16BigEndianInitialization", testUIntX16BigEndianInitialization),
        ("testUIntX64Initialization", testUIntX64Initialization),
        ("testUIntX64BigEndianInitialization", testUIntX64BigEndianInitialization),
        ("testUIntX64ToUIntX8Initialization", testUIntX64ToUIntX8Initialization),
        ("testUIntX8ToUIntX64Initialization", testUIntX8ToUIntX64Initialization),
        ("testUIntX64ToUIntX64Initialization", testUIntX64ToUIntX64Initialization)
    ]
}
