import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showSplash = true
    @State private var skipIntroduction = UserDefaults.standard.bool(forKey: "skipIntroduction")
    @Environment(\.DBMS) var DBMS
    
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
                if skipIntroduction {
                    MainView()
                } else {
                    introductionViewWithButton
                }
            }
        }
    }
    
    var introductionViewWithButton: some View {
        VStack {
            IntroductionView()
            Button(action: {
                UserDefaults.standard.set(true, forKey: "skipIntroduction")
                self.skipIntroduction = true
                (UIApplication.shared.delegate as? AppDelegate)?.startLocationTracking()
            }) { Text("Let's go!").underline()}
                .padding(.bottom)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var measurementsOnLaunch: ScreenMeasurements
    @State var showInfo: Bool = false
    @State var showSettings: Bool = false
    @EnvironmentObject private var isGameOpen: Observable<Bool>
    
    var body: some View {
        VStack {
            if showInfo {
                titleAndBackButton.padding(.top)
                PrivacyInfoView()
            } else if showSettings {
                titleAndBackButton.padding(.top)
                SettingsView()
            } else if isGameOpen.rawValue {
                GameView()
            } else {
                titleAndInfoButton.padding(.top)
                Divider()
                TabPanel()
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
            .environmentObject(TransportBarChartModel(limit: Date(),
                                              DBMS: CoreDataManager()))
            .environment(\.managedObjectContext, DBMS.persistentContainer.viewContext)
    }
}
