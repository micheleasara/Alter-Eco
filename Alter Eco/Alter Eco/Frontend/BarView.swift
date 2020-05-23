import SwiftUI

/// Represents a bar and the respective axis
struct BarView: View {
    
    var value: Double
    var relativeWidth: CGFloat
    var label: String
    var colour: String
    
    var body: some View {
        return VStack() {
                    Rectangle()
                        .foregroundColor(Color(self.colour))
                
                    //Text(self.label)
//                        .font(.caption)
//                        .foregroundColor(Color("secondary_label"))
                        //.rotationEffect(.degrees(-90))
            }
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView(value: 0.5, relativeWidth: 1/24, label: "Hello", colour: "graphBars")
    }
}
