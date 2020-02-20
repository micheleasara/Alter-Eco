//
//  tracker.swift
//  Alter Eco
//
//  Created by Maxime Redstone on 12/02/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation
import CoreLocation

class TrackingData : ObservableObject{
    @Published var distance: Double = 0
    @Published var time: Double = 0
    @Published var speed: Double = 0
    @Published var transportMode: String = "Not automotive"
    @Published var station : String = "Not in a tube station"
}

