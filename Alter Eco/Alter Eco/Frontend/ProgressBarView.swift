import Foundation
import SwiftUI

struct ProgressBarView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    let proportion = try! DBMS.retrieveLatestScore().totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE
    
    var body: some View {
        try! DBMS.updateLeagueIfEnoughPoints()
        
        return VStack {
            Text("Your League")
           .font(.headline)
           .fontWeight(.semibold)
            
            textBoxLeagueInformation
            VStack (spacing: 0) {
                progressBar
                Text("\((try! DBMS.retrieveLatestScore()).totalPoints, specifier: "%.0f") / \(POINTS_REQUIRED_FOR_NEXT_LEAGUE, specifier: "%.0f")")
                        .font(.body)
            }
        }
    }
    
    var textBoxLeagueInformation : some View {
         ZStack() {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
             .frame(width: screenMeasurements.trasversal * 0.9, height: screenMeasurements.longitudinal / 7)
             .foregroundColor(Color("fill_colour"))
          
            if ((try! DBMS.retrieveLatestScore()).league != "🌳") {
                      Text("Grow your forest! You have planted \((try! DBMS.retrieveLatestScore()).counter) 🌳 so far, keep earning points to grow a new 🌳")
                      .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal / 8)
                  }
                   
                 // depending on which league user is in, display next one
            else if ((try! DBMS.retrieveLatestScore()).league == "🌳") {
                     Text("Your forest is thriving! You just planted another 🌳, for a total of \((try! DBMS.retrieveLatestScore()).counter)! Congratulations! You're now growing a new sapling.")
                          .font(.headline)
                          .fontWeight(.regular)
                          .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal/8)
            }
        }
    }
    
    var progressBar : some View {
        HStack{
            Text("\((try! DBMS.retrieveLatestScore()).league)")
            .font(.largeTitle)
            
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal/45)
                    .opacity(0.3)
                    .foregroundColor(Color("fill_colour"))
          
                Rectangle()
                       .frame(width: screenMeasurements.trasversal*CGFloat(0.7*proportion), height: screenMeasurements.longitudinal/45)
                        .foregroundColor(Color("graphBars"))
                        .animation(.linear)
                }.cornerRadius(25.0)

            Text("\(UserScore.getNewLeague(userLeague: (try! DBMS.retrieveLatestScore()).league))")
            .font(.largeTitle)
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView().environmentObject(ScreenMeasurements())
    }
}


