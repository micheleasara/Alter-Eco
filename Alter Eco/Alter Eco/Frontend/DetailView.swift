import SwiftUI

public struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    @ObservedObject var isTrackingPaused = (UIApplication.shared.delegate as! AppDelegate).isTrackingPaused
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                WelcomeView().padding(.top)
                ChartView().frame(height: measurementsOnLaunch.longitudinal / 2)
                
                Button(action: {
                    self.toggleTracking()
                }) {
                    if isTrackingPaused.rawValue {
                        Text("Resume tracking").underline()
                    } else {
                        Text("Pause tracking").underline()
                    }
                }.padding(.bottom)
                
                ProgressBarView().padding(.bottom)

                ComparisonView()

                HighlightView()
            }
        }
    }
    
    func toggleTracking() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isTrackingPaused.rawValue.toggle()
            if appDelegate.isTrackingPaused.rawValue {
                appDelegate.manager.stopUpdatingLocation()
            } else {
                appDelegate.startLocationTracking()
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
            .environmentObject(ChartDataModel(limit: Date().toLocalTime(), DBMS: DBMS))
    }
}
