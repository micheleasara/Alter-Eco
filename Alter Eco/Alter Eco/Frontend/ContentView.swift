import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showSplash = false
    @ObservedObject var isFirstLaunch = (UIApplication.shared.delegate as! AppDelegate).isFirstLaunch
    
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
                MainView()
//                if isFirstLaunch.rawValue {
//                    introductionViewWithButton
//                } else {
//                    tabView
//                }
            }
        }
    }
    
    var introductionViewWithButton: some View {
        VStack {
            IntroductionView()
            Button(action: {
                try? DBMS.setValuesForKeys(entity: "UserPreference", keyedValues: ["firstLaunch":false])
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
                titleAndInfoButton.padding(.top)
                Divider()
                TabPanel()
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
}

struct TabPanel: View {
    var body: some View {
        TabView() {
            ProfileView().padding(.bottom).tabItem {
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
        return ContentView()
           .environmentObject(ScreenMeasurements())
            .environmentObject(ChartDataModel(limit: Date().toLocalTime(),
                                              DBMS: CoreDataManager()))
            .environment(\.managedObjectContext, DBMS.persistentContainer.viewContext)
    }
}
