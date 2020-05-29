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
         RoundedRectangle(cornerRadius: 25, style: .continuous)
             .frame(width: screenMeasurements.trasversal * 0.9, height: screenMeasurements.longitudinal / 7)
             .foregroundColor(Color("fill_colour"))
            .overlay(
                Text(retrieveLabel())
                .minimumScaleFactor(0.01)
                .allowsTightening(true)
                .padding())
    }
    
    func retrieveLabel() -> String {
        let latestScore = try! DBMS.retrieveLatestScore()
        if latestScore.league != "🌳" {
            return "Grow your forest! You have planted \(latestScore.counter ?? 0) 🌳\nKeep earning points to grow a new one."
        } else {
           return "Your forest is thriving! You just planted another 🌳, for a total of \(latestScore.counter!)! Congratulations! You're now growing a new sapling."
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


