//
//  measurement.swift
//  Alter Eco
//
//  Created by Maxime Redstone on 18/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation

let TIME_PRECISION: Double = 1 // 1 second

class MeasuredActivity: Equatable {
    var motionType: MotionType
    var distance: Double
    var start: Date
    var end:Date
    
    init(motionType:MotionType, distance:Double, start:Date, end:Date) {
        self.motionType = motionType
        self.distance = distance
        self.start = start
        self.end = end
    }
    
    static func ==(lhs: MeasuredActivity, rhs: MeasuredActivity) -> Bool {
        let differenceStart = lhs.start.timeIntervalSince(rhs.start)
        let differenceEnd = lhs.end.timeIntervalSince(rhs.end)
        
        return (lhs.motionType == rhs.motionType && lhs.distance == rhs.distance && differenceStart < TIME_PRECISION && differenceEnd < TIME_PRECISION)
    }
    
}

enum MotionType{
    case car
    case walking
    case unknown
}

func motionTypeToString(type:MotionType) -> String {
    switch (type) {
    case .car:
        return "car"
    case .walking:
        return "walking"
    default:
        return ""
    }
}

func stringToMotionType(type:String) -> MotionType {
    switch (type) {
    case "car":
        return .car
    case "walking":
        return .walking
    default:
        return .unknown
    }
}
