import SwiftUI

struct BarView: View {
    
    var value: Double
    var label: String
    //This value represents the addition of the two pickers and used to change the width value in the bar graph
    var wid: Int
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        let AV_UK_DAILYCARBON: Double = 2200
        var colour: String
        if (queryDailyCarbonAll(hourStart: "00:00:00", hourEnd: "24:00:00")>AV_UK_DAILYCARBON)
        {
            colour = "redGraphBar"
        }
        else
        {
            colour = "graphBars"
        }
        //The following two if statements adjust the width of the graph depending on the 'time' picker value chosen. For example, if 'day' is selected then the graph has to change dimensions to fit 12 variables on the x-axis (as opposed to 7 for 'week'). The 'wid' value is the addition of the two picker values.
        if (((wid>=0)&&(wid<=4))||(wid>=10)&&(wid<=14)) {return
            VStack {
                //Graph for 'days' and 'months'
                ZStack(alignment: .bottom) {
                    Capsule().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/18, height:
                        CGFloat(self.screenMeasurements.broadcastedHeight)/4.5)
                        .foregroundColor(Color("app_background"))
                        .opacity(0.0)
                    Rectangle().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/21, height: CGFloat(value) * (CGFloat(self.screenMeasurements.broadcastedHeight)/4.95))
                        .foregroundColor(Color(colour))
                }
                Text(label)
                    .font(Font.system(size: 13.5, design: .default))
                    .padding(.top,CGFloat((self.screenMeasurements.broadcastedWidth)/50))
            }
        }
        return VStack {
            //Graph for 'weeks' and 'years'
            ZStack(alignment: .bottom) {
                Capsule().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/20, height: CGFloat(self.screenMeasurements.broadcastedHeight)/4.5)
                    .foregroundColor(Color("app_background"))
                    .opacity(0.0)
                Rectangle().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/9.2, height: CGFloat(value) * (CGFloat(self.screenMeasurements.broadcastedHeight)/4.95))
                    .foregroundColor(Color(colour))
                }
            Text(label)
                .font(Font.system(size: 13.5, design: .default))
                .padding(.top,CGFloat((self.screenMeasurements.broadcastedWidth)/50))
            }
        }
    
}



