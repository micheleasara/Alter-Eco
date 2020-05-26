import SwiftUI

public struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    
    public var body: some View {
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

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DetailView()
           .environment(\.managedObjectContext, context)
           .environmentObject(ScreenMeasurements())
           .environmentObject(GraphDataModel())
    }
}
