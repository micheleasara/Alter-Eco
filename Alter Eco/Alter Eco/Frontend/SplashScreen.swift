import Foundation
import SwiftUI

public struct SplashScreen: View {
    @State private var percent = 0.0
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    private var animationLength: Double = 2.0

    public var body: some View {
        VStack {
            ZStack {
                Image("earth")
                .resizable()
                .frame(width: screenMeasurements.trasversal*0.25,
                       height:screenMeasurements.trasversal*0.25,
                       alignment: .center)
                
              RotatingAnimation(percent: percent)
                .stroke(Color("app_background"), lineWidth: screenMeasurements.trasversal)
                .rotationEffect(.degrees(360))

              .onAppear() {
                self.handleAnimations()
              }
              .frame(width: screenMeasurements.trasversal*0.15,
                     height: screenMeasurements.trasversal*0.15,
                     alignment: .center)
            }
            
            Text("Alter Eco").font(.largeTitle)
        }
    }
      
    private func handleAnimations() {
      withAnimation(.easeIn(duration: animationLength)) {
        percent = 1
      }
    }
}

public struct RotatingAnimation: Shape {
    public var percent: Double
    private static let MAX_NUM_DEGREES = 360.0
    
    public func path(in rect: CGRect) -> Path {
        let end = percent * RotatingAnimation.MAX_NUM_DEGREES
        var path = Path()

        path.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
            radius: rect.size.width/2,
            startAngle: .degrees(0),
            endAngle: Angle(degrees: end),
            clockwise: true)

        return path
    }
  
    public var animatableData: Double {
    get { return percent }
    set { percent = newValue }
  }
}


struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen().environmentObject(ScreenMeasurements())
    }
}
