import Foundation
import SwiftUI

func generateProportion() -> String {
    
    let currentDateTime = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en-UK")
    
    let value = try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: dateFormatter.string(from: currentDateTime))
    
    let proportion = Int(round(value * 100 / AV_UK_DAILYCARBON))
    
    return ("So far today you've emitted \(proportion)% of the UK daily average carbon emissions.")
}

struct ComparisonView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
          VStack {
              Text("Your Emissions")
                    .font(.headline)
                    .fontWeight(.semibold)
              
              ZStack {
              RoundedRectangle(cornerRadius: 25, style: .continuous)
                  .fill(Color("fill_colour"))
                  .frame(width: screenMeasurements.width*0.9, height: screenMeasurements.height/6)
                  
              Text(generateProportion())
                  .font(.headline)
                  .fontWeight(.regular)
                  .frame(width: screenMeasurements.width*0.7, height: screenMeasurements.height/6)
              }
          }
      }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ComparisonView()
    }
}

