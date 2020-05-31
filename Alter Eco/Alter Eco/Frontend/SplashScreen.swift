import Foundation
import SwiftUI

/// Shows the logo with a rotating animation.
public struct SplashScreen: View {
    @State private var percent = 0.0
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    public static let ANIMATION_LENGTH: Double = 1.8 // in seconds

    public var body: some View {
        ZStack (alignment: .center) {
            Image("earth")
            .resizable()
            .scaledToFit()
            .frame(width: 240,
                   height: 128)
            
          RotatingCircumference(percent: percent)
            .stroke(Color("app_background"), lineWidth: screenMeasurements.trasversal)
            .onAppear() { self.handleAnimations() }
            .frame(width: 120,
                 height: 128)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
      
    private func handleAnimations() {
        withAnimation(.easeIn(duration: SplashScreen.ANIMATION_LENGTH)) {
            percent = 1
        }
    }
}

/// Represents an animatable circumference that increases according to a percentage.
public struct RotatingCircumference: Shape {
    public var percent: Double
    private static let MAX_NUM_DEGREES = 360.0
    
    public func path(in rect: CGRect) -> Path {
        let end = percent * RotatingCircumference.MAX_NUM_DEGREES
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
