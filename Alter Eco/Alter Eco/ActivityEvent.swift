//
//  ActivityEvent.swift
//  Alter Eco
//
//  Created by Maxime Redstone on 19/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation

class ActivityEvent {
    var motionType: MotionType
    var distance: Double
    var duration: Double
    var start: Date
    var end: Date
    
    init(motionType:MotionType, distance:Double, start:Date, end:Date) {
        self.motionType = motionType
        self.distance = distance
        self.start = start
        self.end = end
    }
}
