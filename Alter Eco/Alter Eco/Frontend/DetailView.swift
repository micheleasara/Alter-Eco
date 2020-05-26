import SwiftUI

struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    
    var body: some View {
        ScrollView {
            VStack {
                WelcomeView()
                GraphView().frame(height: measurementsOnLaunch.longitudinal / 2)
                
                Spacer()
                ProgressBarView()

                Spacer()
                ComparisonView()

                Spacer()
                HighlightView()
            }
        }
    }
}
