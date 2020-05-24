import SwiftUI

struct BarWithInfo: View {
    var size: CGSize
    var colour: Color
    var information : String
    @State var showingAlert: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.green)
                .frame(width: size.width, height: size.height)
                .onTapGesture { if !self.information.isEmpty {
                    self.showingAlert.toggle()
                    }
                }
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Value of tapped bar"), message: Text(information), dismissButton: .default(Text("OK")))
        }
    }
}
