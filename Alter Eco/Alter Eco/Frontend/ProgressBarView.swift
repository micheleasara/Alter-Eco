import Foundation
import SwiftUI

struct ProgressBarView: View {

    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var whenViewLoadedCheckIfUserReachedNewLeague: Void = try! DBMS.getLeagueProgress(dbms: DBMS as! CoreDataManager)
    
    let proportion = try! DBMS.retrieveLatestScore().totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE
    
    var body: some View {
        
        VStack {
            Text("Your League")
                .font(.headline)
                .padding(.trailing, CGFloat(screenMeasurements.broadcastedWidth)/2.1)
           
            //text box for league information
            ZStack() {
               RoundedRectangle(cornerRadius: 25, style: .continuous)
                   .frame(width: CGFloat(screenMeasurements.broadcastedWidth) * 0.9, height: CGFloat(screenMeasurements.broadcastedHeight) / 9)
                   .foregroundColor(Color("fill_colour"))
            
                VStack() {
                    
                        if ((try! DBMS.retrieveLatestScore()).league != "🌳") {
                            Text("Grow your plant into a 🌳! Your plant is now a \((try! DBMS.retrieveLatestScore()).league). You have planted \((try! DBMS.retrieveLatestScore()).counter) 🌳 so far, keep going!")
                            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7, height: CGFloat(screenMeasurements.broadcastedHeight)/10)
                        }
                         
                       // depending on which league user is in, display next one
                       else if ((try! DBMS.retrieveLatestScore()).league == "🌳") {
                           Text("Your ecosystem is thriving! You have planted \((try! DBMS.retrieveLatestScore()).counter) 🌳 Congratulations!")
                                .font(.headline)
                                .fontWeight(.regular)
                                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7, height: CGFloat(screenMeasurements.broadcastedHeight)/8)
                       }
                }
           }
 
            //progress bar
            HStack{
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7, height: CGFloat(screenMeasurements.broadcastedHeight)/45)
                        .opacity(0.3)
                        .foregroundColor(Color("fill_colour"))
              
                    
                        Rectangle()
                           .frame(width: (CGFloat(screenMeasurements.broadcastedWidth)*CGFloat(0.7*proportion)), height: CGFloat(screenMeasurements.broadcastedHeight)/45)
                            .foregroundColor(Color("graphBars"))
                            .animation(.linear)
                            
                    }.cornerRadius(25.0)

                Text("\(UserScore.getNewLeague(userLeague: (try! DBMS.retrieveLatestScore()).league))")
                .font(.largeTitle)
            }
          Text("\((try! DBMS.retrieveLatestScore()).totalPoints, specifier: "%.0f") / \(POINTS_REQUIRED_FOR_NEXT_LEAGUE, specifier: "%.0f")")
            .font(.body)
            .padding(.leading, CGFloat(screenMeasurements.broadcastedWidth)/3.2)
            
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView()
    }
}


