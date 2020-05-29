import Foundation
import SwiftUI

public struct ComparisonView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    public var body: some View {
          VStack {
              Text("Your Emissions")
                    .font(.headline)
                    .fontWeight(.semibold)
              
              ZStack {
                  RoundedRectangle(cornerRadius: 25, style: .continuous)
                      .fill(Color("fill_colour"))
                      .frame(width: screenMeasurements.trasversal*0.9, height: screenMeasurements.longitudinal/7)
                    .overlay(
                      Text(generateProportion())
                        .allowsTightening(true)
                        .padding())
              }
          }
      }
    
    private func generateProportion() -> String {
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en-UK")
        let now = Date()
        let value = try! DBMS.carbonFromPollutingMotions(from: Date.setToSpecificHour(date: now, hour: "00:00:00")!, interval: DAY_IN_SECONDS)
        
        let proportion = Int(round(value * 100 / AVERAGE_UK_DAILY_CARBON))
        
        return ("So far today you've emitted \(proportion)% of the UK daily average carbon emissions.")
    }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ComparisonView().environmentObject(ScreenMeasurements())
    }
}

