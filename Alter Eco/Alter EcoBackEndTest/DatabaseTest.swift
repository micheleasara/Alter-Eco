import XCTest
import CoreLocation
import CoreData
@testable import AlterEcoBackend

class DatabaseTest: XCTestCase {
    
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
        try! DBMS.append(foods: [food])
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
        
        DBMS.addNewPollutingItemCallback(callback: {type in expectation.fulfill()})
        try! DBMS.append(activity: testActivity)

        // wait for the expectation to be fullfilled, or time out after 5 seconds
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testScoreIsInitialized() {
        let retrieved = try! DBMS.retrieveLatestScore() // retrieves initialized score
        XCTAssert(retrieved == 0)
    }
    
    func testUpdatedUserScoreIsRetrieved() {
        let activity1 = MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100))
        let activity2 = MeasuredActivity(motionType: .train, distance: 1000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 1000))
        
        try! DBMS.updateScore(activity: activity1)
        try! DBMS.updateScore(activity: activity2)
        let retrieved = try! DBMS.retrieveLatestScore()
        XCTAssert(retrieved == activity1.equivalentPoints + activity2.equivalentPoints,
                  String(format: "retrieved = %f is not equal to %f", retrieved, activity1.equivalentPoints + activity2.equivalentPoints))
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
    
}
