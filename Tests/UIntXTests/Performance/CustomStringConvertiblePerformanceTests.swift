import Foundation
import XCTest
@testable import UIntX

final class CustomStringConvertiblePerformanceTests: XCTestCase {

    func testDescription() {
        UIntXConfig.maximumNumberOfWords = Int.max; defer { UIntXConfig.maximumNumberOfWords = 128 }
        let sut = UIntX8(littleEndianArray: [UInt8](repeating: 0b10101010, count: 131_072))

        measure {
            XCTAssertEqual(sut.description.count, 262_146)
        }
    }
}
