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
            Text("Should update every 50 meters\n")
            
            Text("Distance: \(trackingData.distance, specifier: "%.0f") m")
            Text("Time elapsed: \(trackingData.time, specifier: "%.0f") s")
            Text("Average Speed: \(trackingData.speed, specifier: "%.2f") m/s")
            
            Text("\nMode of transport: \(trackingData.transportMode)")
            Text("\(trackingData.station)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
