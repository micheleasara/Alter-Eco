import SwiftUI
import MapKit

struct ContentView: View {
    @State var showSplash = true

    var body: some View {
        ZStack{
            SplashScreen()
            .opacity(showSplash ? 1 : 0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation() {
                        self.showSplash = false
                    }
                }
            }
            if (!self.showSplash) {
                tabView
            }
        }
    }
    
    var tabView : some View {
        TabView(){
            DetailView()
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats").font(.title)
                    }
                }

            ProfileView()
                    .tabItem {
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
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView()
           .environment(\.managedObjectContext, context)
           .environmentObject(ScreenMeasurements())
           .environmentObject(GraphDataModel())
    }
}
