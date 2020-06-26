import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showSplash = false
    @ObservedObject var isFirstLaunch = (UIApplication.shared.delegate as! AppDelegate).isFirstLaunch
    private(set) var DBMS: DBManager
    
    var body: some View {
        ZStack {
            SplashScreen()
                .opacity(showSplash ? 1 : 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + SplashScreen.ANIMATION_LENGTH) {
                        withAnimation() {
                            self.showSplash = false
                        }
                    }
            }
            
            if !self.showSplash {
                if isFirstLaunch.rawValue {
                    introductionViewWithButton
                } else {
                    MainView(DBMS: DBMS)
                }
            }
        }
    }
    
    var introductionViewWithButton: some View {
        VStack {
            IntroductionView()
            Button(action: {
                try? self.DBMS.setValuesForKeys(entity: "UserPreference", keyedValues: ["firstLaunch":false])
                // refresh UI and display tabView
                let delegate = (UIApplication.shared.delegate as! AppDelegate)
                delegate.isFirstLaunch.rawValue = false
                delegate.startLocationTracking()
            }) { Text("Let's go!").underline()}
                .padding(.bottom)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var measurementsOnLaunch : ScreenMeasurements
    @State var showInfo: Bool = false
    @State var showSettings: Bool = false
    private(set) var DBMS: DBManager
    
     var body: some View {
        VStack {
            if showInfo {
                titleAndBackButton.padding(.top)
                PrivacyInfoView()
            }
            else if showSettings {
                titleAndBackButton.padding(.top)
                SettingsView(DBMS: DBMS)
            }
            else {
                titleAndInfoButton.padding(.top)
                Divider()
                TabPanel(DBMS: DBMS)
            }
        }
    }

    var titleAndInfoButton: some View {
        HStack() {
            Spacer()
            HStack {
                Title()
                Button(action: {
                    self.showInfo.toggle()
                }) {
                    Image(systemName: "info.circle") }
            }.offset(x: 10)
            
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
}

struct TabPanel: View {
    private(set) var DBMS: DBManager
    
    var body: some View {
        TabView() {
            ProfileView(DBMS: DBMS).padding(.bottom).tabItem {
                VStack {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            }
            
            TransportView().padding(.bottom).tabItem {
                VStack {
                    Image(systemName: "car")
                    Text("Transport")
                }
            }
            
            FoodView().padding(.bottom).tabItem {
                Image(systemName: "cart")
                Text("Groceries")
            }
        }.onAppear() {
            (UIApplication.shared.delegate as? AppDelegate)?.requestNotificationsPermission()
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let DBMS = CoreDataManager()
        return ContentView(DBMS: DBMS)
           .environmentObject(ScreenMeasurements())
            .environmentObject(TransportBarChartModel(limit: Date().toLocalTime(),
                                              DBMS: CoreDataManager()))
            .environment(\.managedObjectContext, DBMS.persistentContainer.viewContext)
    }
}
