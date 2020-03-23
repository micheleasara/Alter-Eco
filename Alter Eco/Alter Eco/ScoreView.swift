import SwiftUI

struct ScoreView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var body: some View {
    
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedHeight)/5)
                    

            HStack {
                Text("My score: 635 points")
                
                Image("silver_medal")
                    .scaleEffect(0.5)
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
    }
}
