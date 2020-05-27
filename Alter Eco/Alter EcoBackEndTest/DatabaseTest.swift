import XCTest
import CoreLocation
import CoreData
@testable import AlterEcoBackend

class DatabaseTest: XCTestCase {
    
    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
    }
    
    func testDatabaseIOIsConsistent() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let activity = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: activity)
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [longTimeAgo as NSDate, someTimeAgo as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(activity == retrieved[0])
    }
    
    func testDatabaseCannotFindNonExistantData() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [longTimeAgo as NSDate, someTimeAgo as NSDate])
        XCTAssert(retrieved.count == 0)
    }
    
    func testCallbackIsCalledWhenActivityIsWritten() {
        let expectation = self.expectation(description: "callback")
        let testActivity = MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        
        DBMS.setActivityWrittenCallback(callback: {activity in expectation.fulfill()})
        try! DBMS.append(activity: testActivity)

        // wait for the expectation to be fullfilled, or time out after 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testScoreIsInitializedWhenRetrievingTheFirstTime() {
        let initial = try! DBMS.retrieveLatestScore() // initializes the first time
        let retrieved = try! DBMS.retrieveLatestScore() // retrieves initialized score
        XCTAssert(retrieved == initial)
    }
    
    func testUpdatedUserScoreIsRetrieved() {
        let activity1 = MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        let activity2 = MeasuredActivity(motionType: .train, distance: 1000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 1000))
        let score1 = UserScore(activity: activity1, league: "", date: "", counter: 0)
        let score2 = UserScore(activity: activity2, league: "", date: "", counter: 0)
        
        _ = try! DBMS.retrieveLatestScore() // initialize score row
        try! DBMS.updateScore(activity: activity1)
        try! DBMS.updateScore(activity: activity2)
        try! DBMS.updateLeague(newLeague: "abc")
        let retrieved = try! DBMS.retrieveLatestScore()
        XCTAssert(retrieved.totalPoints == score1.totalPoints + score2.totalPoints)
        XCTAssert(retrieved.league == "abc")
    }
    
    func testDatabaseCanGetFirstActivity() {
        let recently = Date.init(timeIntervalSince1970: 1000)
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        
        let old = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: old)
        let new = MeasuredActivity(motionType: .car, distance: 100, start: someTimeAgo, end: recently)
        try! DBMS.append(activity: new)
        XCTAssert(try! DBMS.getFirstDate() == old.start)
    }
    
    func testQueryForDistanceRetrieval() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        
        for motion in MeasuredActivity.MotionType.allCases {
            let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
            try! DBMS.append(activity: old)
        }
        let distance = try! DBMS.distanceWithinIntervalAll(from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
        XCTAssert(distance == Double(MeasuredActivity.MotionType.allCases.count))
    }
    
    func testQueryForCarbonRetrieval() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        var carbonExpected = 0.0
        
        for motion in MeasuredActivity.MotionType.allCases {
            if motion != .walking {
                let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
                carbonExpected += DBMS.computeCarbonUsage(distance: 1, type: motion)
                try! DBMS.append(activity: old)
            }
        }
        let retrievedCarbon = try! DBMS.carbonWithinIntervalAll(from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
        XCTAssert(retrievedCarbon == carbonExpected)
    }
    
}
