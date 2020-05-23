import Foundation
import SwiftUI

struct ProgressBarView: View {

    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var whenViewLoadedCheckIfUserReachedNewLeague: Void = try! DBMS.updateLeagueIfEnoughPoints()
    
    let proportion = try! DBMS.retrieveLatestScore().totalPoints / POINTS_REQUIRED_FOR_NEXT_LEAGUE
    
    var body: some View {
        
        VStack {
            Text("Your League")
           .font(.headline)
           .fontWeight(.semibold)
            
            //text box for league information
            ZStack() {
               RoundedRectangle(cornerRadius: 25, style: .continuous)
                   .frame(width: screenMeasurements.width * 0.9, height: screenMeasurements.height / 7)
                   .foregroundColor(Color("fill_colour"))
            
                VStack() {
                    
                        if ((try! DBMS.retrieveLatestScore()).league != "🌳") {
                            Text("Grow your forest! You have planted \((try! DBMS.retrieveLatestScore()).counter) 🌳 so far, keep earning points to grow a new 🌳!")
                            .frame(width: screenMeasurements.width*0.7, height: screenMeasurements.height / 8)
                        }
                         
                       // depending on which league user is in, display next one
                       else if ((try! DBMS.retrieveLatestScore()).league == "🌳") {
                           Text("Your forest is thriving! You just planted another 🌳, for a total of \((try! DBMS.retrieveLatestScore()).counter)! Congratulations! You're now growing a new sapling.")
                                .font(.headline)
                                .fontWeight(.regular)
                                .frame(width: screenMeasurements.width*0.7, height: screenMeasurements.height/8)
                       }
                }
           }
 
            //progress bar
            HStack{
                Text("\((try! DBMS.retrieveLatestScore()).league)")
                .font(.largeTitle)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: screenMeasurements.width*0.7, height: screenMeasurements.height/45)
                        .opacity(0.3)
                        .foregroundColor(Color("fill_colour"))
              
                    
                        Rectangle()
                           .frame(width: screenMeasurements.width*CGFloat(0.7*proportion), height: screenMeasurements.height/45)
                            .foregroundColor(Color("graphBars"))
                            .animation(.linear)
                            
                    }.cornerRadius(25.0)

                Text("\(UserScore.getNewLeague(userLeague: (try! DBMS.retrieveLatestScore()).league))")
                .font(.largeTitle)
            }
          Text("\((try! DBMS.retrieveLatestScore()).totalPoints, specifier: "%.0f") / \(POINTS_REQUIRED_FOR_NEXT_LEAGUE, specifier: "%.0f")")
            .font(.body)
            .padding(.leading, screenMeasurements.width/3.5)
            
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView()
    }
}


