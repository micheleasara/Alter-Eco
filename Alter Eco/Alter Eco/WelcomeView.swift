import SwiftUI

struct WelcomeView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        
        HStack {
            Text("Hello Alter Ecoer")
            .foregroundColor(Color("title_colour"))
            .font(.largeTitle)
            
            Image(systemName: "person.crop.circle")
            .imageScale(.large)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
