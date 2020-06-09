import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showSplash = true
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
                if isFirstLaunch.rawValue {
                    introductionViewWithButton
                } else {
                    tabView
                }
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
    
    
    var tabView : some View {
        TabView() {
            DetailView().padding(.bottom).tabItem {
                VStack {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats").font(.title)
                }
            }

            ProfileView().padding(.bottom).tabItem {
                VStack {
                    Image(systemName: "person.circle")
                    Text("Profile").font(.title)
                }
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
