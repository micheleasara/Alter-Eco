import SwiftUI

struct BarView: View {
        
    var value: Double
    var label: String
    
    //This value represents the addition of the two pickers and used to change the width value in the bar graph
    var wid: Int
    
    var body: some View {
        
        //The following two if statements adjust the width of the graph depending on the 'time' picker value chosen. For example, if 'day' is selected then the graph has to change dimensions to fit 12 variables on the x-axis (as opposed to 7 for 'week'). The 'wid' value is the addition of the two picker values.
        if (((wid>=0)&&(wid<=4))||(wid>=10)&&(wid<=14)) {return
        VStack {
      
            //Graph for 'days' and 'months'
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 20, height:  CGFloat(200))
                    .foregroundColor(Color("app_background"))
                    .opacity(0.0)
                Rectangle().frame(width: 20, height: CGFloat(value*130))
                    .foregroundColor(Color("graphBars"))
            }
            Text(label)
                .padding(.top,CGFloat(8))
        }
    }
        return
        VStack {
            //Graph for 'weeks' and 'years'
                ZStack(alignment: .bottom) {
                    Capsule().frame(width: 38.5, height: CGFloat(200))
                        .foregroundColor(Color("app_background"))
                        .opacity(0.0)
                    Rectangle().frame(width: 38.5, height: CGFloat(value*130))
                        .foregroundColor(Color("graphBars"))
                }
                Text(label)
                    .padding(.top,CGFloat(8))
          
            }
        }
}


