import SwiftUI

 struct TransportView: View {
    @EnvironmentObject var measurementsOnLaunch: ScreenMeasurements
    @ObservedObject var isTrackingPaused = (UIApplication.shared.delegate as! AppDelegate).isTrackingPaused
    @EnvironmentObject var awards: TransportAwardsManager
    @EnvironmentObject var pieChartModel: TransportPieChartModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                TransportBarChart().frame(height: measurementsOnLaunch.longitudinal / 2.5)

                Button(action: {
                    self.toggleTracking()
                }) {
                    if isTrackingPaused.rawValue {
                        HStack {
                            Text("Resume tracking")
                            Image(systemName: "play.circle.fill")
                        }
                    } else {
                       HStack {
                            Text("Pause tracking")
                            Image(systemName: "pause.circle.fill")
                        }
                    }
                }
                
                if pieChartModel.values.reduce(0, +) > 0 {
                    PieChart(model: pieChartModel)
                        .padding()
                        .frame(width: 0.8*measurementsOnLaunch.trasversal,
                               height: 0.8*measurementsOnLaunch.trasversal)
                        .padding(.horizontal)
                } else {
                    PieChart.empty()
                        .frame(width: 0.45*measurementsOnLaunch.trasversal,
                               height: 0.45*measurementsOnLaunch.trasversal,
                               alignment: .center)
                }
                
                Text("Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                AwardView(awardsManager: awards)
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
        let DBMS = CoreDataManager()
        return TransportView()
           .environmentObject(ScreenMeasurements())
            .environmentObject(TransportBarChartModel(limit: Date().toLocalTime(), DBMS: DBMS))
            .environmentObject(TransportAwardsManager(DBMS: DBMS))
            .environmentObject(TransportPieChartModel(DBMS: DBMS))
    }
}
