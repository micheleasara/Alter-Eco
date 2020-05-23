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
                        .padding(.bottom, -screenMeasurements.height / 30)

                    //Bar chart view
                    GraphView()

                    //Progress Bar
                   ProgressBarView()
                       .padding(.bottom, screenMeasurements.height / 35)

                   //Comparisons
                   ComparisonView()
                       .padding(.bottom, screenMeasurements.height / 35)

                   //Highlights
                   HighlightView()

                   Spacer(minLength: screenMeasurements.height*0.04)

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
