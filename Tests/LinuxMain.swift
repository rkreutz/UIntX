import XCTest

@testable import UIntXTests

var tests = [XCTestCaseEntry]()
tests += UIntXComparableTests.allTests
tests += UIntXDescription.allTests
tests += UIntXHash.allTests
tests += UIntXInitTests.allTests
tests += UIntXLeftShiftTests.allTests
tests += UIntXOperations.allTests
tests += UIntXRightShiftTests.allTests
XCTMain(tests)
