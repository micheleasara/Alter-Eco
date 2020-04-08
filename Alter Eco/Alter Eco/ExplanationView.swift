import Foundation
import SwiftUI

struct ExplanationView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
       
    var body: some View {
       
        VStack {
            
            Text("Your Graph Scores:")
            
            Text("The graph shows you the amount of carbon dioxide grams you emitted from taking your modes of transport. We convert every metre in a car to 175 grams, every metre on a train to 30 grams and every metre flown to 200 grams! Walking is displayed as the amount of carbon dioxide you saved instead of driving!")
            
            Text("Your Graph Colour:")
            
            Text("Keep an eye out on the graph changing colour! Green shows you that you have emmitted less than (or equal to) the average UK citizen that day (2200 grams of carbon dioxide) and a red graph shows that you have emitted more than the average!")
            
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
