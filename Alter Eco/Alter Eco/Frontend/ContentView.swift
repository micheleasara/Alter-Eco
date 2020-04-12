import SwiftUI
import MapKit

struct ContentView: View {

    @State var showSplash = true
    @State private var selection = 0
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

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
                TabView(selection: $selection){
                    DetailView()
                        .tabItem {
                            VStack {
                                Image(systemName: "chart.bar.fill")
                                Text("Stats").font(.title)

                            }
                        }
                    .tag(0)

                        ProfileView()
                            .tabItem {
                            VStack {
                                Image(systemName: "person.circle")
                                Text("Profile").font(.title)
                            }
                        }
                    .tag(1)

                }
            }
        }
    }
}

