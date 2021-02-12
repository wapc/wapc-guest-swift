import XCTest
@testable import wapc

final class wapcTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(wapc().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
