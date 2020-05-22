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
                        .padding(.bottom, -screenMeasurements.broadcastedHeight / 30)
                    
                    //Bar chart view
                    GraphView()
                    
                    //Progress Bar
                   ProgressBarView()
                       .padding(.bottom, screenMeasurements.broadcastedHeight / 35)
                   
                   //Comparisons
                   ComparisonView()
                       .padding(.bottom, screenMeasurements.broadcastedHeight / 35)
                   
                   //Highlights
                   HighlightView()
                   
                   Spacer(minLength: screenMeasurements.broadcastedHeight*0.04)
                       
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
