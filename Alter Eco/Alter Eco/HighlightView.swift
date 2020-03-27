import SwiftUI

//data for conversions to CO2 of food production comes from:
//https://www.businessinsider.com/the-top-10-foods-with-the-biggest-environmental-footprint-2015-9?IR=T

//data for conversion to oxygen production of trees comes from:
//https://www.eea.europa.eu/articles/forests-health-and-climate-change/key-facts/trees-help-tackle-climate-change

/*
func conversion() -> String {
    
    
}
*/
struct HighlightView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
            
        ZStack {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color("fill_colour"))
            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/3)

            VStack{
                    Text("Highlights")
                        .font(.headline)
            
           // Text(conversion())
            }

        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}
