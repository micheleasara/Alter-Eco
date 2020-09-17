import Foundation
import SwiftUI

public struct PrivacyInfoView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    private let MAIL_ADDRESS = "alterecodeveloper@gmail.com"
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                contact.padding()
                privacyAndData.padding()
                credits.padding()
            }
        }
    }
    
    private var mailButton: some View {
        Button(action: {
            let url: NSURL = URL(string: "mailto:" + self.MAIL_ADDRESS)! as NSURL

            UIApplication.shared.open(url as URL)

        }) {
            Text("alterecodeveloper@gmail.com")
            .underline()
        }
    }
    
    private var contact: some View {
        VStack(alignment: .leading) {
            Text("Feedback")
                .bold()
                Text("All feedback is welcome!\nIf you have suggestions, bug reports or anything similar, please drop us an e-mail at:")
                    .fontWeight(.regular)
                mailButton
        }.fixedSize(horizontal: false, vertical: true)
    }
    
    private var privacyAndData: some View {
        VStack(alignment: .leading) {
            Text("Privacy and Data")
            .bold()
            
            Text("We care about your privacy! We want you to feel comfortable using our app and knowing that your data is protected.\n\nThat is why all of your information is stored locally on your device, and can not be seen by anybody else - not even us at Alter Eco! This includes all your transport data, food habits, profile pictures, nicknames and even which awards you have won.\n\nIf you  would like to remove your data from your device, simply delete the app from your phone.")
                    .fontWeight(.regular)
                    .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var credits : some View {
        VStack(alignment: .leading) {
            Text("Credits")
            .bold()
            Text("Icons made by Freepik, Flat Icon and Prosymbols from www.flaticon.com")
                    .fontWeight(.regular)
                    .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyInfoView().environmentObject(ScreenMeasurements())
    }
}
