import SwiftUI

struct DetailView: View {
    
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        ScrollView {
            ZStack {
                Color("app_background")
                
                VStack {
                    Spacer()
                    //welcome, and profile button
                    WelcomeView()
                        .padding(.bottom, -CGFloat(screenMeasurements.broadcastedHeight / 30))
                    
                    //Bar chart view
                    GraphView()
                    
                    //Scores summary
                    //ScoreView()
                    
                    //Progress Bar
                    ProgressBarView()
                        .padding(.bottom, CGFloat(screenMeasurements.broadcastedHeight / 25))
                    
                    //Highlights
                    HighlightView()
                        
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
