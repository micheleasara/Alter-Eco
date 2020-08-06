import Foundation
import SwiftUI

struct ProgressBarView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private var showingInfo = false
    @State private(set) var latestScore: UserScore
    @Environment(\.DBMS) var DBMS

    var body: some View {
        try? DBMS.updateLeagueIfEnoughPoints()
        
        return VStack {
            scoreLabelWithInfo
            
            textBoxLeagueInformation
            VStack (spacing: 0) {
                progressBar
                Text("\(latestScore.totalPoints, specifier: "%.0f") / \(POINTS_REQUIRED_FOR_NEXT_LEAGUE, specifier: "%.0f")")
                        .font(.body)
            }
        }
    }
    
    var scoreLabelWithInfo: some View {
        HStack(alignment: .center) {
            Text("Score: ").font(.headline)
            + Text("\(latestScore.totalPoints, specifier: "%.0f")")
                .font(.headline)

        
        Button(action: {self.showingInfo = true}) {
            Image(systemName: "info.circle")
        }
            .alert(isPresented: $showingInfo) {
                Alert(title: Text("Your Eco Score"), message: Text("We estimate your modes of transport throughout the day. The more eco-friendly your commute is, the more points you earn!"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    var textBoxLeagueInformation: some View {
         RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color("fill_colour"))
             .frame(width: screenMeasurements.trasversal * 0.9, height: screenMeasurements.longitudinal / 7)
            .overlay(
                Text(retrieveLabel())
                .minimumScaleFactor(0.01)
                .allowsTightening(true)
                .padding())
    }
    
    func retrieveLabel() -> String {
        if latestScore.league != "🌳" {
            return "You have planted \(latestScore.counter ?? 0) 🌳\nKeep earning points to grow your forest!"
        } else {
           return "Your forest is thriving! You just planted another 🌳, for a total of \(latestScore.counter ?? 1)! Congratulations! You're now growing a new sapling."
        }
    }
    
    var progressBar : some View {
        let proportion = getProportion()
        return HStack{
            Text("\(latestScore.league)")
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
        let DBMS = CoreDataManager()
        
        return ProgressBarView(latestScore: (try? DBMS.retrieveLatestScore()) ?? UserScore.getInitialScore())
            .environmentObject(ScreenMeasurements())
            .environmentObject(TransportBarChartModel(limit: Date(), DBMS: DBMS))
    }
}


