import XCTest
@testable import UIntX

final class UIntXHash: XCTestCase {

    func testHash() {

        XCTAssertEqual(UIntX8(1).hashValue, UIntX8(ascendingArray: [1] as [UInt]).hashValue)
        XCTAssertEqual(UIntX8(1_234).hashValue, UIntX8(ascendingArray: [1_234] as [UInt]).hashValue)
        XCTAssertEqual(UIntX8(0x1234).hashValue, UIntX8(ascendingArray: [0x34, 0x12] as [UInt8]).hashValue)
    }

    static let allTests = [
        ("testHash", testHash)
    ]
}
