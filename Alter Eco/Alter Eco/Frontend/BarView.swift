import SwiftUI

/// Represents a bar and the respective axis
struct BarView: View {
    
    var height: Double
    var label: String
    //This value represents the addition of the two pickers which is used to change the width value in the bar graph as if day view is selected than the width will have to be larger than if a week view is selected.
    var timePickerSelection: Int
    var colour: String
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        //The following two if statements adjust the width of the graph depending on the 'time' picker value chosen. For example, if 'day' is selected then the graph has to change dimensions to fit 12 variables on the x-axis (as opposed to 7 for 'week'). The 'wid' value is the addition of the two picker values.
        if (timePickerSelection == 0 || timePickerSelection == 2) {
            return barWithLabel(colour: colour, axisWidth: 24)
        }
        // For 'weeks' and 'years'
        return barWithLabel(colour: colour, axisWidth: 10)
    }
    
    func barWithLabel(colour: String, axisWidth: CGFloat) -> some View {
        return VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: self.screenMeasurements.broadcastedWidth/20, height: self.screenMeasurements.broadcastedHeight/4.5)
                    .foregroundColor(Color("app_background"))
                    .opacity(0.0)
                Rectangle().frame(width: self.screenMeasurements.broadcastedWidth/axisWidth, height: CGFloat(height) * self.screenMeasurements.broadcastedHeight/4.95)
                    .foregroundColor(Color(colour))
            }
            
            Text(label)
                .font(Font.system(size: 13.5, design: .default))
                .padding(.top,self.screenMeasurements.broadcastedWidth/50)
            }
    }
}


//struct BarView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarView(height: 1, label: "test", timePickerSelection: 5).environmentObject(ScreenMeasurements())
//    }
//}
