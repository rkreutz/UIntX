import XCTest
@testable import UIntX

final class UIntXComparableTests: XCTestCase {

    func testComparable() {

        XCTAssertLessThan(UIntX8(0x12345), 0x54321)
        XCTAssertLessThan(UIntX8(0x00012345), 0x54321)

        XCTAssertLessThan(UIntX16(ascendingArray: [0x2, 0x1] as [UInt]), UIntX16(ascendingArray: [0x1, 0x2] as [UInt]))

        XCTAssertLessThan(UIntX32(ascendingArray: [0x2, 0x1] as [UInt]), UIntX32(ascendingArray: [0x1, 0x2] as [UInt]))

        XCTAssertLessThan(UIntX64(ascendingArray: [0x2, 0x1] as [UInt]), UIntX64(ascendingArray: [0x1, 0x2] as [UInt]))
    }

    static var allTests = [
        ("testComparable", testComparable)
    ]
}
