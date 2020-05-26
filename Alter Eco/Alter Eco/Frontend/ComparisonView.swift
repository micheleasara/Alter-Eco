import Foundation
import SwiftUI

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
                      .frame(width: screenMeasurements.trasversal*0.9, height: screenMeasurements.longitudinal/6)
                      
                  Text(generateProportion())
                      .font(.headline)
                      .fontWeight(.regular)
                      .frame(width: screenMeasurements.trasversal*0.7, height: screenMeasurements.longitudinal/6)
              }
          }
      }
    
    func generateProportion() -> String {
        let currentDateTime = Date()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en-UK")
        
        let value = try! DBMS.queryHourlyCarbonAll(hourStart: "00:00:00", hourEnd: dateFormatter.string(from: currentDateTime))
        
        let proportion = Int(round(value * 100 / AV_UK_DAILYCARBON))
        
        return ("So far today you've emitted \(proportion)% of the UK daily average carbon emissions.")
    }
  }

struct ComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        ComparisonView().environmentObject(ScreenMeasurements())
    }
}

