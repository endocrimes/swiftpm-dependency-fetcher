import XCTest
@testable import swiftpm_dependency_fetcher

class swiftpm_dependency_fetcherTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(swiftpm_dependency_fetcher().text, "Hello, World!")
    }


    static var allTests : [(String, (swiftpm_dependency_fetcherTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
