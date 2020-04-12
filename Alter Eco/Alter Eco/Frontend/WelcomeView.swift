import SwiftUI

struct WelcomeView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        
        HStack {
            Text("My Alter Eco")
            .foregroundColor(Color("title_colour"))
            .font(.largeTitle)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
