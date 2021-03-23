import XCTest
@testable import AlterEcoBackend

class MultiTimerTest: XCTestCase {

    let timers = MultiTimer()
    
    func testStart() {
        let expectation = self.expectation(description: "start")
         timers.start(key: "test", interval: 0.01) {
            // OK to proceed
            expectation.fulfill()
        }

        // wait for the expectation to be fullfilled, or time out after 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testStop() {
        timers.start(key: "test", interval: 5) {
            // should never get here
                XCTFail()
        }
        timers.stop("test")
    }
}
