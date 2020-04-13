//
//  DatabaseTest.swift
//  Alter EcoBackEndTest
//
//  Created by Virtual Machine on 26/03/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import XCTest
import CoreLocation
import CoreData
@testable import Alter_Eco

class DatabaseTest: XCTestCase {
    
    var DBMS: CoreDataManager!

    override func setUp() {
        super.setUp()
        DBMS = CoreDataManager(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).mockPersistentContainer())
    }
    
    func testDatabaseIOIsConsistent(){
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let activity = MeasuredActivity(motionType: .plane, distance: 10000, start: longTimeAgo, end: someTimeAgo)
        try! DBMS.append(activity: activity)
        let retrieved = try! DBMS.queryActivities(query: NSPredicate(format: "start == %@ AND end == %@", longTimeAgo as NSDate, someTimeAgo as NSDate))
        XCTAssert(retrieved.count == 1)
        XCTAssert(activity == retrieved[0])
    }
    
    func testDatabaseCannotFindNonExistantData(){
        let someTimeAgo = Date.init(timeIntervalSince1970: 100)
        let longTimeAgo = Date.init(timeIntervalSince1970: 1)
        let retrieved = try! DBMS.queryActivities(query: NSPredicate(format: "start == %@ AND end == %@", longTimeAgo as NSDate, someTimeAgo as NSDate))
        XCTAssert(retrieved.count == 0)
    }
}
