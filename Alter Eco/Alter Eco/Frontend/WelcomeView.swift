import SwiftUI

struct WelcomeView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private var showingInfo = false
    
    var body: some View {
        
        HStack {
            Text("My Alter Eco")
            .foregroundColor(Color("title_colour"))
            .font(.largeTitle)
            
            Button(action: {self.showingInfo = true}) {
                Image(systemName: "info.circle")
            }
                .alert(isPresented: $showingInfo) {
                    Alert(title: Text("Your Eco Graph"), message: Text("The Alter Eco graph shows you the amount of carbon dioxide you emitted from your transport - completely automatically! If you walk, the graph displays how much carbon dioxide you saved instead of driving. A green graph means you're emitting less carbon than the average Londoner, and red means your doing worse."), dismissButton: .default(Text("OK")))
                }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
