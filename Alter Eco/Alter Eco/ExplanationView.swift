import Foundation
import SwiftUI

struct ExplanationView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
       
    var body: some View {
        
        VStack {
            
            Text("Your Eco Score:")
        
            Text("We estimate your modes of transport throughout the day. Walking gets you 10 points. That's a lot of points! If you take the tube you gain 7 points! You only gain 3 points by taking the car. Unfortunately, we don't award any points for taking the plane. Gain more points to move up our Alter Eco Leagues!")
            
            Text("Your Eco League:")
            
            Text("In the Alter Eco community, your league defines you! The greener the transport modes you use,the more points you accumulate. Compete against yourself, improve your carbon footprint and you will soon be part of the élite Alter Ecoers that are in the League Tortoise!!")
        }
    }
}

struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationView()
    }
}
