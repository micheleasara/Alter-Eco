import Foundation
import SwiftUI

public struct ComparisonView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private(set) var dailyCarbon: Double
    
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
                        .minimumScaleFactor(0.01)
                        .allowsTightening(true)
                        .padding())
              }
          }
      }
    
    private func generateProportion() -> String {
        let proportion = Int(round(dailyCarbon * 100 / AVERAGE_UK_DAILY_CARBON))
        return ("So far today you've emitted \(proportion)% of the UK daily average carbon emissions.")
    }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        let DBMS = CoreDataManager()
        return ComparisonView(dailyCarbon: try! DBMS.carbonFromPollutingMotions(from: now.setToSpecificHour(hour: "00:00:00")!.toGlobalTime(), interval: DAY_IN_SECONDS))
            .environmentObject(ScreenMeasurements())
            .environmentObject(TransportBarChartModel(limit: Date(), DBMS: DBMS))
    }
}

