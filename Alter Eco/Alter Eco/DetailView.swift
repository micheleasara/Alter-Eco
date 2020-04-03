import SwiftUI

struct DetailView: View {
    
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State var progressValue: Float = 0.2
    
    var body: some View {
        ScrollView {
            ZStack {
                Color("app_background")
                
                VStack {
                
                    //welcome, and profile button
                    WelcomeView()
                    
                    //Bar chart view
                    GraphView()
                    
                    //Scores summary
                    //ScoreView()
                    
                    //Progress Bar
                    ProgressBarView(value: $progressValue)
                    
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
