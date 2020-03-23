import SwiftUI

struct HighlightView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
            
        ZStack {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color("fill_colour"))
            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/5)

            VStack{
                    Text("Highlights")
                        .font(.headline)
            
            Text("This week you've consumed 27% less carbon than last week. Well done! Only three more carbon units until the gold medal!")
            }

        }
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView()
    }
}
