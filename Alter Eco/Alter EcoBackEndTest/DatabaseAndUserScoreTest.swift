import XCTest
import CoreLocation
import CoreData
@testable import AlterEcoBackend

class DatabaseAndUserScoreTest: XCTestCase {
    
    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager()
        DBMS.persistentContainer = mockPersistentContainer(managedObject: DBMS.managedObjectModel)
    }
    
    // the following function is for integrations tests
    // it generates a synchronous and volatile database
    func mockPersistentContainer(managedObject: NSManagedObjectModel) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Database2.0", managedObjectModel: managedObject)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
                                        
            // Check if creating container wrong
            if let error = error {
                print("An error occurred: \(error)")
            }
        }
        return container
    }
    
    func testDatabaseIsEmptyForTheseTests() {
        let results = try! DBMS.queryActivities()
        XCTAssert(results.isEmpty)
    }
    
    func testActivityIOIsConsistent() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let activity = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: activity)
        let retrieved = try! DBMS.queryActivities(predicate: "start == %@ AND end == %@", args: [longTimeAgo as NSDate, someTimeAgo as NSDate])
        XCTAssert(retrieved.count == 1)
        XCTAssert(activity == retrieved[0])
    }
    
    func testFoodIOIsConsistent() {
        let food = Food(barcode: "12345678")
        try! DBMS.append(food: food)
        let retrieved = try! DBMS.queryFoods(predicate: "barcode == %@", args: ["12345678"])
        XCTAssert(retrieved.count == 1)
        XCTAssert(food == retrieved[0])
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
        
        DBMS.addActivityWrittenCallback(callback: {activity in expectation.fulfill()})
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
    
    func testCarbonRetrievalOfPollutingMotions() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        var carbonExpected = 0.0
        
        for motion in MeasuredActivity.MotionType.allCases {
            if motion.isPolluting() {
                let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
                carbonExpected += DBMS.computeCarbonUsage(distance: 1, type: motion)
                try! DBMS.append(activity: old)
            }
        }
        let retrievedCarbon = try! DBMS.carbonFromPollutingMotions(from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
        XCTAssert(retrievedCarbon == carbonExpected)
    }
    
    func testCarbonRetrievalOfNonPollutingMotions() {
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        
        for motion in MeasuredActivity.MotionType.allCases {
            if !motion.isPolluting() {
                let old = MeasuredActivity(motionType: motion, distance: 1, start: longTimeAgo, end: someTimeAgo)
                let carbonExpected = DBMS.computeCarbonUsage(distance: 1, type: motion)
                try! DBMS.append(activity: old)
                
                let retrievedCarbon = try! DBMS.carbonWithinInterval(motionType: motion, from: longTimeAgo, interval: someTimeAgo.timeIntervalSince(longTimeAgo))
                XCTAssert(retrievedCarbon == carbonExpected)
            }
        }
    }
    
    func testPrintsNextLeagueFromScore() {
        
        let initialUserScore = UserScore.getInitialScore()
        let userScoreAtLeague2 = UserScore.getInitialScore()
        userScoreAtLeague2.league = "🌿"
        let userScoreAtLeague3 = UserScore.getInitialScore()
        userScoreAtLeague3.league = "🌳"
        
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        let currentScores = [initialUserScore, userScoreAtLeague2]
        
        let nextLeagueFromInitialScore = UserScore.getNewLeague(userLeague: initialUserScore.league)
        let nextLeagueFromScoreAtLeague2 = UserScore.getNewLeague(userLeague: userScoreAtLeague2.league)
        let nextLeagueFromScoreAtLeague3 = UserScore.getNewLeague(userLeague: userScoreAtLeague3.league)
        
        XCTAssert(nextLeagueFromInitialScore == currentLeagues[currentScores.count-1], "Can not retrieve next league from initial score.")
        XCTAssert(nextLeagueFromScoreAtLeague2 == currentLeagues[currentScores.count], "Can not retrieve next league from user at league 2.")
        XCTAssert(nextLeagueFromScoreAtLeague3 == currentLeagues[currentScores.count-2], "Can not retrieve next league from user at league 3.")
        
    }
    
    func testDoesNotUpdateLeagueIfNotEnoughPointsAccumulated() {
    
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        try! DBMS.updateLeagueIfEnoughPoints()
        
        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[0], "Does not upgrade league if not enough points. ")
    }
    
    func testCanUpdateLeagueWhenEnoughPointsAccumulated() {
    
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        try! DBMS.updateScore(activity: MeasuredActivity(motionType: .walking, distance: 400000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: DAY_IN_SECONDS)))
        
        try! DBMS.updateLeagueIfEnoughPoints()
        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[1], "Should upgrade user league in database from league 1 to league 2.")
        XCTAssert(updatedScore.totalPoints == 0.0, "Updating league should reset user score.")
    }
        
    func testCanUpdateCounterWhenMaxLeagueIsReached() {
        
        _ = try! DBMS.retrieveLatestScore()
        let currentLeagues = ["🌱", "🌿", "🌳"]
        
        for _ in stride(from: 0, to: 3, by: 1) {
            try! DBMS.updateScore(activity: MeasuredActivity(motionType: .car, distance: 1001000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 60*60)))
            try! DBMS.updateLeagueIfEnoughPoints()
        }

        let updatedScore = try! DBMS.retrieveLatestScore()
        
        XCTAssert(updatedScore.league == currentLeagues[0], "Should go back to league 1.")
        XCTAssert(updatedScore.totalPoints == 0.0, "Updating league should reset user score.")
        XCTAssert(updatedScore.counter == 1, "After completing the 3 leagues should go back to league one and counter should increase by 1.")
    }
    
}
