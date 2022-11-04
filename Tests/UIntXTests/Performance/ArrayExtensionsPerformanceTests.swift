import Foundation
import XCTest
@testable import UIntX

final class ArrayExtensionsPerformanceTests: XCTestCase {
    func testRemovingFirst() {
        var array = [UInt8](repeating: 0, count: 1_048_576)
        array[array.index(before: array.endIndex)] = 1

        measure {
            let sut = array.removingFirst(where: { $0 == 0 })
            XCTAssertEqual(sut.count, 1)
        }
    }
}
