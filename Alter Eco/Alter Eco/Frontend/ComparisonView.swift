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
        let proportion = dailyCarbon / AVERAGE_UK_DAILY_CARBON
        if proportion <= 1 {
            return String(format: "So far today you've emitted %.0f%% of the UK daily average carbon emissions.", proportion * 100)
        } else {
            // only display up to 1sd if necessary
            let emissions = (proportion / 0.1).rounded() * 0.1
            return String(format: "So far today you've emitted %g times the UK daily average carbon emissions.", emissions)
        }
    }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        let DBMS = CoreDataManager()
        return Group {
            ComparisonView(dailyCarbon: try! DBMS.carbonFromPollutingMotions(from: now.toLocalTime().setToSpecificHour(hour: "00:00:00")!.toGlobalTime(), interval: DAY_IN_SECONDS))
            .environmentObject(ScreenMeasurements()).previewLayout(.fixed(width: 400, height: 200))
            
            ComparisonView(dailyCarbon: AVERAGE_UK_DAILY_CARBON*2.333)
            .environmentObject(ScreenMeasurements()).previewLayout(.fixed(width: 400, height: 200))
        }
    }
}

