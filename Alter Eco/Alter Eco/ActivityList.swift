////
////  ActivityList.swift
////  Alter Eco
////
////  Created by Virtual Machine on 11/04/2020.
////  Copyright © 2020 Imperial College London. All rights reserved.
////
//
//import Foundation
//
//protocol ActivityList {
//    
//    func getCumulativeDistance() -> Double
//    func getAverageMotionType() -> MeasuredActivity.MotionType
//    
//    func computeChangeInActivity()
//    func hasChangedSignificantly() -> Bool
//    func isFull() -> Bool
//    func getAverage() -> MeasuredActivity
//    
//    func add()
//    func remove()
//    
//}
//
//public class WeigthedActivityList: ActivityList {
//    
//    var measurements: [MeasuredActivity] = []
//    var activityWeights: [MeasuredActivity.MotionType: Int]
//    var numChangeActivity: Int
//    
//    init(activityWeights: [MeasuredActivity.MotionType: Int], numChangeActivity: Int ) {
//        self.activityWeights = activityWeights
//        self.numChangeActivity = numChangeActivity
//    }
//    
//    public func getCumulativeDistance() -> Double {
//        var distance = 0.0
//        for measurement in measurements {
//            distance += measurement.distance
//        }
//        return distance
//    }
//    
//    public func getAverageMotionType() -> MeasuredActivity.MotionType {
//        var carCounter = 0
//        var walkingCounter = 0
//
//        for measurement in measurements {
//            if measurement.motionType == .car {
//                carCounter += 1
//            }
//            else {
//                walkingCounter += 1
//            }
//        }
//
//        if carCounter * activityWeights[.car]! > walkingCounter {
//            return .car
//        }
//        else {
//            return .walking
//        }
//    }
//    
////    public func computeChangeInActivity() {
////        
////    }
//    
//    public func hasChangedSignificantly() -> Bool {
//        if measurements.count < numChangeActivity { return false }
//        
//        let rootType = measurements[0].motionType
//        
//        var previousLastType: MeasuredActivity.MotionType? = nil
//        
//        for index in (measurements.count-numChangeActivity-1)..<(measurements.count) {
//            let lastType = measurements[index].motionType
//            if lastType == rootType || (previousLastType != nil && previousLastType != lastType) {
//                return false
//            }
//            previousLastType = lastType
//        }
//        
//        return true
//    }
//    
////    public func isFull() -> Bool {
////        <#code#>
////    }
////
////    public func getAverage() -> MeasuredActivity {
////        <#code#>
////    }
////
////    public func add() {
////        <#code#>
////    }
////
////    public func remove() {
////        <#code#>
////    }
////
//    
//}
