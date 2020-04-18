import SwiftUI

struct BarView: View {
    
    var value: Double
    var label: String
    //This value represents the addition of the two pickers which is used to change the width value in the bar graph as if day view is selected than the width will have to be larger than if a week view is selected.
    var wid: Int
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        
       
        //The colour of the graph will change depending on whether the user has emitted more or less than the UK's daily average.
        let colour = findGraphColour()
        //The following two if statements adjust the width of the graph depending on the 'time' picker value chosen. For example, if 'day' is selected then the graph has to change dimensions to fit 12 variables on the x-axis (as opposed to 7 for 'week'). The 'wid' value is the addition of the two picker values.
        if (((wid>=0)&&(wid<=4))||(wid>=10)&&(wid<=14)) {return
            VStack {
                //Graph for 'days' and 'months'
                ZStack(alignment: .bottom) {
                    Capsule().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/20, height:
                        CGFloat(self.screenMeasurements.broadcastedHeight)/4.5)
                        .foregroundColor(Color("app_background"))
                        .opacity(0.0)
                    Rectangle().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/24, height: CGFloat(value) * (CGFloat(self.screenMeasurements.broadcastedHeight)/4.95))
                        //Colour is determined by the daily carbon query above
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
                Rectangle().frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)/10, height: CGFloat(value) * (CGFloat(self.screenMeasurements.broadcastedHeight)/4.95))
                    //Colour is determined by the daily carbon query above
                    .foregroundColor(Color(colour))
                }
            //Labels displayed below the graph represent the different time points.
            Text(label)
                .font(Font.system(size: 13.5, design: .default))
                .padding(.top,CGFloat((self.screenMeasurements.broadcastedWidth)/50))
            }
        }
}



