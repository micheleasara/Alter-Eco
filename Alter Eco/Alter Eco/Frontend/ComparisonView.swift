import Foundation
import SwiftUI

func generateProportion() -> String {
    
    let currentDateTime = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    
    let value = try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: dateFormatter.string(from: currentDateTime))
    
    let proportion = Int(round(value * 100 / AV_UK_DAILYCARBON))
    
    return ("So far today you've consumed \(proportion)% of the UK daily average.")
}

struct ComparisonView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
          VStack {
              Text("Your Emissions")
                  .font(.headline)
                  .padding(.trailing, CGFloat(screenMeasurements.broadcastedWidth)/2.5)
              
              ZStack {
              RoundedRectangle(cornerRadius: 25, style: .continuous)
                  .fill(Color("fill_colour"))
                  .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/6)
                  
              Text(generateProportion())
                  .font(.headline)
                  .fontWeight(.regular)
                  .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7, height: CGFloat(screenMeasurements.broadcastedHeight)/6)
              }
          }
      }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ComparisonView()
    }
}

