import Foundation
import XCTest
@testable import UIntX

final class UIntXExtensionsPerformanceTests: XCTestCase {
    func testMax() {
        UIntXConfig.maximumNumberOfWords = 131_072; defer { UIntXConfig.maximumNumberOfWords = 128 }

        measure {
            XCTAssertEqual(UIntX8.max.bitWidth, 1_048_576)
        }
    }
}
