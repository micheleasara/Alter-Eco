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
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let DBMS = CoreDataManager(persistentContainer: container)
        return DetailView()
           .environmentObject(ScreenMeasurements())
           .environmentObject(GraphDataModel(DBMS: DBMS))
    }
}
