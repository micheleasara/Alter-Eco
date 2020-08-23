import XCTest
import CoreLocation
import CoreData
@testable import AlterEcoBackend

class DatabaseTest: XCTestCase {
    
    var DBMS: CoreDataManager!
    let foodConverterMock = FoodToCarbonConverterMock()
    
    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(foodConverter: foodConverterMock)
        DBMS.persistentContainer = mockPersistentContainer(managedObject: DBMS.managedObjectModel)
    }
    
    // the following function is for tests
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
    
    func testTotalCarbonRetrievalIncludesFoodAndTransport() {
        let start = Date(timeIntervalSince1970: 0)
        let activity = MeasuredActivity(motionType: .car, distance: 10000, start: start, end: start.addingTimeInterval(100))
        let food = Food(barcode: "123", quantity: Food.Quantity(value: 140, unit: UnitMass.grams), types: FoodToCarbonManager.getAvailableTypes())
        try! DBMS.append(foods: [food], withDate: start)
        try! DBMS.append(activity: activity)
        
        let result = try! DBMS.carbonWithinInterval(from: start, addingInterval: 200).value
        XCTAssert(result == DBMS.computeCarbonUsage(distance: activity.distance, type: activity.motionType) + foodConverterMock.getCarbon(fromFood: food)!.value)
    }
    
    func testAllEntriesInATableCanBeDeleted() {
        for _ in 0..<4 {
            try! DBMS.append(activity: MeasuredActivity(motionType: .car, distance: 10000, start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)))
        }
        XCTAssertFalse(try! DBMS.queryActivities(predicate: nil, args: nil).isEmpty)
        
        try! DBMS.deleteAll(entity: "Event")
        XCTAssert(try! DBMS.queryActivities(predicate: nil, args: nil).isEmpty)
    }
    
    func testEntryCanBeDeletedByIndex() {
        for i in 0..<4 {
            try! DBMS.append(activity: MeasuredActivity(motionType: .car, distance: Double(i), start: Date(timeIntervalSince1970: 0), end: Date(timeIntervalSince1970: 100)))
        }
        
        let beforeDelete = try! DBMS.queryActivities(predicate: nil, args: nil)
        try! DBMS.delete(entity: "Event", rowNumber: 1)
        let afterDelete = try! DBMS.queryActivities(predicate: nil, args: nil)
        
        for activity in afterDelete {
            XCTAssert(beforeDelete.contains(activity))
        }
        XCTAssertFalse(afterDelete.contains(beforeDelete[1]))
    }
    
    func testForestItemsIOIsConsistent() {
        let item = ForestItem(id: "123", x: 0, y: 3, z: 6, internalName: "fake")
        try! DBMS.saveForestItem(item)
        let stored = try! DBMS.getForestItems()
        XCTAssert(stored == [item], "stored = \(stored)\nitem = \(item)")
    }
    
    func testForestItemIsUpdatedIfAlreadyExistant() {
        var item = ForestItem(id: "123", x: 0, y: 3, z: 6, internalName: "fake")
        try! DBMS.saveForestItem(item)
        item.internalName = "changed"
        item.x = 11
        try! DBMS.saveForestItem(item)
        let stored = try! DBMS.getForestItems()
        XCTAssert(stored == [item], "stored = \(stored)\nitem = \(item)")
    }
}
