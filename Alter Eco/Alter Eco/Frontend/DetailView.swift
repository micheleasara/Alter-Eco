import SwiftUI

 struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    @ObservedObject var isTrackingPaused = (UIApplication.shared.delegate as! AppDelegate).isTrackingPaused
    @State var showInfo: Bool = false
    @State var showSettings: Bool = false
    
     var body: some View {
        VStack {
            if showInfo {
                titleAndBackButton.padding(.top)
                PrivacyInfoView()
            }
            else if showSettings {
                titleAndBackButton.padding(.top)
                SettingsView()
            }
            else {
                titleAndInfoButton
                    //.frame(maxWidth: .infinity)
                    .padding(.top)
                stats
            }
        }
    }

    var titleAndInfoButton: some View {
        HStack() {
            Spacer()
            Title()
            Button(action: {
                self.showInfo.toggle()
            }) {
                Image(systemName: "info.circle") }
            
            Spacer()
            Button(action: {
                self.showSettings.toggle()
                }) {
                    Image(systemName: "gear")
            }.padding(.trailing)
        }
    }
    
    var titleAndBackButton: some View {
        ZStack(alignment: .leading) {
            Button(action: {
                self.showInfo = false
                self.showSettings = false
            }) { Text("Back").padding(.leading) }
                Title().frame(maxWidth: .infinity,
                       alignment: .center)
        }
    }
    
    var stats: some View {
        ScrollView {
            VStack(alignment: .center) {
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
        let DBMS = CoreDataManager()
        return DetailView()
           .environmentObject(ScreenMeasurements())
            .environmentObject(ChartDataModel(limit: Date().toLocalTime(), DBMS: DBMS))
    }
}
