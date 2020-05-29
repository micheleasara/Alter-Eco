import SwiftUI
import MapKit

struct ContentView: View {
    @State var showSplash = true
    @FetchRequest(entity: UserPreference.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \UserPreference.firstLaunch, ascending: true)]) var preferences: FetchedResults<UserPreference>
    @Environment(\.managedObjectContext) var context

    
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
                if isFirstLaunch() {
                    introductionViewWithButton
                } else {
                    tabView
                }
            }
        }
    }
    
    func isFirstLaunch() -> Bool {
        // for loop executes only if data is present
        for preference in preferences {
            return preference.firstLaunch
        }
        // by default, assume first launch
        return true
    }
    
    var introductionViewWithButton: some View {
        VStack {
            IntroductionView()
            Button(action: {
                let pref = UserPreference(context: self.context)
                pref.firstLaunch = false
                try? self.context.save()
                
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
