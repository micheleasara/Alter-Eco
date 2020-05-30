import SwiftUI

public struct WelcomeView: View {
    @State private var showingInfo = false
    
    public var body: some View {
        HStack {
            Text("My Alter Eco")
            .foregroundColor(Color("title_colour"))
            .font(.largeTitle)
            
            Button(action: {self.showingInfo = true}) {
                Image(systemName: "info.circle")
            }.alert(isPresented: $showingInfo) {
                Alert(title: Text("Your Eco Chart"), message: Text("The Alter Eco chart displays your CO2 emissions automatically!\n\n") + Text("If you walk, the chart displays how much carbon you saved instead of driving.\n\n") + Text("Green bars mean you're emitting less than the average Londoner does in a day, and red means you are doing worse."),
                          dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
