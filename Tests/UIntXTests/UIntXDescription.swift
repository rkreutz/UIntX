import XCTest
@testable import UIntX

final class UIntXDescription: XCTestCase {

    func testDescription() {

        XCTAssertEqual(UIntX8(123_456_789).description, "123456789")
        XCTAssertEqual(UIntX16(123_456_789).description, "123456789")
        XCTAssertEqual(UIntX32(123_456_789).description, "123456789")
        XCTAssertEqual(UIntX64(123_456_789).description, "123456789")

        XCTAssertEqual(UIntX8(ascendingArray: [0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1] as [UInt]).description, "0x010101010101010101")
        XCTAssertEqual(UIntX16(ascendingArray: [0x1, 0x1, 0x1, 0x1, 0x1] as [UInt]).description, "0x00010001000100010001")
        XCTAssertEqual(UIntX32(ascendingArray: [0x1, 0x1, 0x1] as [UInt]).description, "0x000000010000000100000001")
        XCTAssertEqual(UIntX64(ascendingArray: [0x1, 0x1] as [UInt]).description, "0x00000000000000010000000000000001")
    }

    static let allTests = [
        ("testDescription", testDescription)
    ]
}
