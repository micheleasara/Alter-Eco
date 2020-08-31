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
                .frame(height: 80)
            basicInformation.padding()
        }
    }
    
    var basicInformation: some View {
        ScrollView {
            VStack (alignment:.leading) {
                Text("What is this app about?").bold()
                Text("Alter Eco is a way for you to track your greenhouse emissions. The more eco-friendly you are, the more points you will earn! You can then spend points to build a virtual forest.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("How does it work?").bold()
                Text("The software tries to determine what kind of transportation you take and computes the emissions associated with it. Also, you can scan the barcodes of different food items to retrieve information about their carbon footprint.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("What about my privacy?").bold()
                Text("Your data is stored only on your device and not shared with anyone. If you want to erase it, simply delete the app. For the best experience, we recommend to allow Alter Eco to track you in the background.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
