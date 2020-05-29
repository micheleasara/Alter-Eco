import SwiftUI

public struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    @State var userPausedTracking = (UIApplication.shared.delegate as? AppDelegate)?.userPausedTracking

    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                WelcomeView()
                GraphView().frame(height: measurementsOnLaunch.longitudinal / 2)
                
                Button(action: {
                    self.toggleTracking()
                    if self.userPausedTracking != nil && self.userPausedTracking! == false {
                        // remove reminders for paused tracking
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                }) {
                    if userPausedTracking ?? false {
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
            appDelegate.userPausedTracking.toggle()
            self.userPausedTracking = appDelegate.userPausedTracking
            if appDelegate.userPausedTracking {
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
            .environmentObject(GraphDataModel(limit: Date(), DBMS: DBMS))
    }
}
