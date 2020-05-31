import SwiftUI

struct Title: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Alter Ec").font(
                .system(.title, design: .rounded)).bold()
                .foregroundColor(
                    Color.init(red: 0, green: 0.7, blue: 0.3))
            Text("O")
                .font(.title)
                .bold()
                .hidden()
                .overlay(
                    Image("earth").resizable().scaledToFit())
        }
    }
}

struct Title_Previews: PreviewProvider {
    static var previews: some View {
        Title()
    }
}
