import SwiftUI

 struct DetailView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    @ObservedObject var isTrackingPaused = (UIApplication.shared.delegate as! AppDelegate).isTrackingPaused
//    public var body: some View {
//
//        NavigationView {
//            VStack(spacing: 0) {
//                HStack {
//                Text("My Alter Eco")
//                .foregroundColor(Color("title_colour"))
//                .font(.largeTitle)
//
//                NavigationLink(destination: PrivacyInfoView()) {
//                        Image(systemName: "info.circle")
//                    }
//                }
//                test
//            }
//        }.navigationBarTitle("Profile", displayMode: .inline)
//        .navigationBarItems(trailing: NavigationLink(destination: PrivacyInfoView())
//        {
//            Text("Info")
//        })
//
//    }
    
     var body: some View {
        NavigationView() {
            stats
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: NavigationLink(destination: PrivacyInfoView())
            {
                HStack(alignment:.center) {
                        Text("My Alter Eco")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.primary)
                        Image(systemName: "info.circle")
                }.frame(width: measurementsOnLaunch.longitudinal, alignment: .center)
            })
        }

    }

    
    var stats: some View {
        ScrollView {
            VStack(alignment: .center) {
                ChartView().frame(height: measurementsOnLaunch.longitudinal / 2).padding(.top)

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
