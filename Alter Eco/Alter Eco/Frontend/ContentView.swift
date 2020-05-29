import SwiftUI
import CoreLocation

struct ContentView: View {
    @State var showSplash = true
    @State var isFirstLaunch: Bool = (UIApplication.shared.delegate as! AppDelegate).isFirstLaunch
    
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
                if isFirstLaunch {
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
                delegate.isFirstLaunch = false
                self.isFirstLaunch = false
                delegate.startLocationTracking()
            }) { Text("Let's go!").underline()}
                .padding(.bottom)
        }
    }
    
    
    var tabView : some View {
        TabView() {
            DetailView().tabItem {
                VStack {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats").font(.title)
                }
            }

            ProfileView().tabItem {
                VStack {
                    Image(systemName: "person.circle")
                    Text("Profile").font(.title)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        return ContentView()
           .environmentObject(ScreenMeasurements())
            .environmentObject(GraphDataModel(limit: Date(),
                                              DBMS: CoreDataManager(persistentContainer: container)))
            .environment(\.managedObjectContext, container.viewContext)
    }
}
