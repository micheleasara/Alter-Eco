import Foundation
import SwiftUI

struct ExplanationView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
       
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                privacyAndData
                Spacer()
                credits
            }
        }
    }
    
    var privacyAndData: some View {
        Group {
            Text("Privacy and Data")
            .bold()
            
            VStack (alignment: .leading){
                Text("We care about your privacy! We want you to feel comfortable using our app and knowing that your data is protected.")
                    .fontWeight(.regular)
                    .frame(width: screenMeasurements.trasversal*0.9, alignment: .leading)
                    .padding()
                
                Text("That is why all of your information is stored locally on your device, and can not be seen by anybody else - not even us at Alter Eco! This includes all your transport data, profile pictures, nicknames and even which awards you have won.")
                    .fontWeight(.regular)
                    .frame(width: screenMeasurements.trasversal*0.9, alignment: .leading)
                    .padding()
                
                Text("If you  would like to remove your data from your device, simply delete the app from your phone.")
                    .fontWeight(.regular)
                    .frame(width: screenMeasurements.trasversal*0.9, alignment: .leading)
                    .padding()
            }
        }
    }
    
    var credits : some View {
        Group {
            Text("Credits")
            .bold()
            
            Text("Icons made by Freepik and Prosymbols from Flaticon.")
                    .fontWeight(.regular)
                .frame(width: screenMeasurements.trasversal*0.9, alignment: .leading).padding()
        }
    }
}

struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationView().environmentObject(ScreenMeasurements())
    }
}
