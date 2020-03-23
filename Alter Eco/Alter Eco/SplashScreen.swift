import Foundation
import SwiftUI

struct SplashScreen:

View {
    @State var percent = 0.0
    let uLineWidth: CGFloat = 140

    var body: some View {
        VStack {
            ZStack {
                Image("earth")
                .resizable()
                .scaledToFit()
                .offset(x: 19, y: 0)
                .frame(width: CGFloat(100.0),height:CGFloat(100), alignment: .center)
                
              FuberU(percent: percent)
                .stroke(Color("app_background"), lineWidth: uLineWidth)
                .rotationEffect(.degrees(360))
                .offset(x: 19, y: 0)
                .aspectRatio(1, contentMode: .fit)
                .padding(20)

              .onAppear() {
                self.handleAnimations()
              }
              .frame(width: 45, height: 45, alignment: .center)
                    }
            Text("Alter Eco")
            .foregroundColor(Color("title_colour"))
            .font(.largeTitle)
            .multilineTextAlignment(.center)
        }
    }
}

extension SplashScreen {
  var uAnimationDuration: Double { return 2.0 }
    
  func handleAnimations() {
    runAnimationPart1()
  }

  func runAnimationPart1() {
    withAnimation(.easeIn(duration: uAnimationDuration)) {
      percent = 1
    }
  }
}


struct FuberU: Shape {
  var percent: Double
  
  
  func path(in rect: CGRect) -> Path {
    let end = percent * 360
    var p = Path()

    
    p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
             radius: rect.size.width/2,
             startAngle: .degrees(0),
             endAngle: Angle(degrees: end),
             clockwise: false)

    return p
  }
  
  var animatableData: Double {
    get { return percent }
    set { percent = newValue }
  }
}
