import SwiftUI

struct IntroductionView: View {
    var body: some View {
        VStack {
            Text("Welcome to Alter Eco!")
                .font(Font.title)
                .bold()
                .padding(.top)
            
            Image("earth").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            basicInformation.padding()
        }
    }
    
    var basicInformation: some View {
        ScrollView {
            VStack (alignment:.leading) {
                Text("What is this app about?").bold()
                Text("Alter Eco is a way for you to track your carbon dioxide production.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("How does it work?").bold()
                Text("By using the GPS, the software tries to determine what kind of transportation you take and computes the carbon associated with it. Also, you can scan the barcodes of different food items to retrieve information about their carbon footprint.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("What about my privacy?").bold()
                Text("Your data is stored only on your device and not shared with anyone. If you want to erase it, simply delete the app. For the best experience, we recommend to allow Alter Eco to track you in the background.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("What about my battery?").bold()
                Text("Alter Eco minimizes its battery impact by stopping the tracking when appropriate. Of course, you are always free to pause or resume it whenever you want!")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
