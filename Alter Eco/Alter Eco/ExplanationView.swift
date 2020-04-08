import Foundation
import SwiftUI

struct ExplanationView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
       
    var body: some View {
        ScrollView {
            VStack {
               Spacer()
                Text("Your Eco Graph:")
                    .bold()
                
                Text("The Alter Eco graph shows you the amount of carbon dioxide you emitted from taking different modes of transport. Walking is the greenest form of transport! The walking option on the graph displays the carbon dioxide you saved instead of driving! Keep an eye out on the graph changing colour! Green shows you that you have emmitted less than (or equal to) the average UK citizen that day (2200 grams of carbon dioxide) and a red graph shows that you have emitted more than the average!")
                        .fontWeight(.regular)
                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9)
                
                Spacer(minLength: CGFloat(screenMeasurements.broadcastedHeight)*0.05)
                
                Text("Your Eco Score:")
                    .bold()
                
                Text("We estimate your modes of transport throughout the day. Walking gets you 10 points. That's a lot of points! If you take the tube you gain 7 points! You only gain 3 points by taking the car. Unfortunately, we don't award any points for taking the plane. Gain more points to move up our Alter Eco Leagues!")
                    .fontWeight(.regular)
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9)
                
                Spacer(minLength: CGFloat(screenMeasurements.broadcastedHeight)*0.05)
                
                Text("Your Eco League:")
                    .bold()
                
               Text("In the Alter Eco community, your league defines you! The greener the transport modes you use,the more points you accumulate. Compete against yourself, improve your carbon footprint and you will soon be part of the élite Alter Ecoers that are in the League Tortoise!!")
                    .fontWeight(.regular)
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9)
            }
        }
    }
}

struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationView()
    }
}
