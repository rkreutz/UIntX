import XCTest
@testable import UIntX

final class UIntXInitTests: XCTestCase {

    func testInitialization() {

        XCTAssertEqual(UIntX<UInt8>(ascendingArray: [0x1234, 0x1, 0x2] as [UInt]), 0x02011234)
        XCTAssertEqual(UIntX<UInt8>(ascendingArray: [1, 2] as [UInt]), 0x0201)
        
        XCTAssertEqual(UIntX<UInt8>(ascendingArray: [1, 0, 2, 0, 0, 0, 0] as [UInt]), 0x020001)
        XCTAssertEqual(UIntX<UInt8>(ascendingArray: [1, 0, 2, 0, 0, 0, 0] as [UInt]).parts.count, 3)

        XCTAssertEqual(UIntX<UInt16>(ascendingArray: [0x1234, 0x1, 0x2] as [UInt]), 0x000200011234)
        XCTAssertEqual(UIntX<UInt16>(ascendingArray: [1, 2] as [UInt16]), 0x00020001)
        XCTAssertEqual(UIntX<UInt16>(ascendingArray: [1, 2] as [UInt8]), 0x00020001)
        XCTAssertEqual(UIntX<UInt16>(ascendingArray: [1, 2] as [UInt]), 0x00020001)

        XCTAssertEqual(UIntX<UInt32>(ascendingArray: [1, 2] as [UInt]), 0x0000000200000001)
        
        // Has to use the `description` since this is storing 2 64-bit values, which overflows the default values in the compiler
        XCTAssertEqual(UIntX<UInt>(ascendingArray: [1, 2] as [UInt]).description, "0x00000000000000020000000000000001")
    }

    static let allTests = [
        ("testInitialization", testInitialization)
    ]
}
