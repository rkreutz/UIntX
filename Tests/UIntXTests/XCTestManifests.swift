import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(UIntXComparableTests.allTests),
        testCase(UIntXDescription.allTests),
        testCase(UIntXHash.allTests),
        testCase(UIntXInitTests.allTests),
        testCase(UIntXLeftShiftTests.allTests),
        testCase(UIntXOperations.allTests),
        testCase(UIntXRightShiftTests.allTests)
    ]
}
#endif
