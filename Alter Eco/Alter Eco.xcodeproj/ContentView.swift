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
                DetailView()
            }
        }
    }
}

