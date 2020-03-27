import SwiftUI

struct ScoreView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    //find score in database for yesterday
    let userScore = retrieveScore(query: NSPredicate(format: "date == %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    
    var body: some View {
    
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/10)
                    
            HStack {
                //display the total score
                Text("Total Score: \(updateScore(score: userScore).totalPoints)" )
                    .font(.title)
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
    }
}
