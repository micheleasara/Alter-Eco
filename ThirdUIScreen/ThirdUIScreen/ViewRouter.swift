//
//  ViewRouter.swift
//  ThirdUIScreen
//
//  Created by Satisfaction on 26/01/2020.
//  Copyright © 2020 Satisfaction. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ViewRouter: ObservableObject {
    //Published tells the observing views to update the variable when
    //user changes page
    @Published var currentView = "home"
    
}
