import Foundation
import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    // needed to refresh points when new activity is written
    @EnvironmentObject var chartData : ChartDataModel
    
    var body: some View {
        try? DBMS.updateLeagueIfEnoughPoints()
        
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
            return "You have planted \(latestScore.counter ?? 0) 🌳\nKeep earning points to grow your forest!"
        } else {
           return "Your forest is thriving! You just planted another 🌳, for a total of \(latestScore.counter ?? 1)! Congratulations! You're now growing a new sapling."
        }
    }
    
    var progressBar : some View {
        let proportion = getProportion()
        return HStack{
            Text("\((try! DBMS.retrieveLatestScore()).league)")
            .font(.largeTitle)
            
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal/45)
                    .opacity(0.3)
                    .foregroundColor(Color("fill_colour"))
          
                Rectangle()
                    .frame(width:
                        screenMeasurements.trasversal * 0.7 * proportion,
                           height: screenMeasurements.longitudinal/45)
                        .foregroundColor(Color("graphBars"))
                        .animation(.linear)
                }.cornerRadius(25.0)

            Text("\(UserScore.getNewLeague(userLeague: (try! DBMS.retrieveLatestScore()).league))")
            .font(.largeTitle)
        }
    }
    
    func getProportion() -> CGFloat {
        let score = try? DBMS.retrieveLatestScore().totalPoints
        let proportion = (score ?? 0.0) / POINTS_REQUIRED_FOR_NEXT_LEAGUE
        return CGFloat(proportion)
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let DBMS = CoreDataManager(persistentContainer: container)
        
        return ProgressBarView()
            .environmentObject(ScreenMeasurements())
            .environmentObject(ChartDataModel(limit: Date().toLocalTime(), DBMS: DBMS))
    }
}


