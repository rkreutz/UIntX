import XCTest
@testable import UIntX

final class UIntXEquatable: XCTestCase {

    func testEquatable() {

        XCTAssertEqual(UIntX8(1), UIntX8(littleEndianArray: [1] as [UInt8]))
        XCTAssertEqual(UIntX8(1_234), UIntX8(littleEndianArray: [1_234] as [UInt16]))
        XCTAssertEqual(UIntX8(0x1234), UIntX8(littleEndianArray: [0x34, 0x12] as [UInt8]))
    }

    static let allTests = [
        ("testEquatable", testEquatable)
    ]
}
