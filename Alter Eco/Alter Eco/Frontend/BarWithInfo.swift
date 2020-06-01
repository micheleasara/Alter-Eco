import SwiftUI

public struct BarWithInfo: View {
    public var size: CGSize
    public var colour: Color
    public var information : String
    @State private var showingAlert: Bool = false
    
    public var body: some View {
        ZStack {
            Rectangle().fill(colour)
                .frame(width: size.width, height: size.height)
                .onTapGesture { if !self.information.isEmpty {
                    self.showingAlert.toggle()
                    }
                }
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text(information).fontWeight(.regular))
        }
    }
}

struct BarWithInfo_Previews: PreviewProvider {
    static var previews: some View {
        BarWithInfo(size: CGSize(width: 20, height: 80), colour: Color.green, information: "Hello, World!")
    }
}
