//
//  ContentView.swift
//  tracker
//
//  Created by Maxime Redstone on 12/02/2020.
//  Copyright © 2020 Maxime Redstone. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View{
    @EnvironmentObject var trackingData: TrackingData
    
    var body: some View {
        VStack {
            Text("Hello you, thanks for testing our app")
            Text("Should update every 50 meters \n Automotive if above 25 km/h \nIgnore the first readings\n")
            
            Text("Distance: \(trackingData.distance) m")
            Text("Time elapsed: \(trackingData.time) s")
            Text("Average Speed: \(trackingData.speed) m/s")
            Text("Mode of transport: \(trackingData.transportMode)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
