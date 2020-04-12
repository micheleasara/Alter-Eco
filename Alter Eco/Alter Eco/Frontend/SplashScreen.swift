import Foundation
import SwiftUI

struct SplashScreen:

View {
    @State var percent = 0.0
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    

    var body: some View {
        
        VStack {
            ZStack {
                Image("earth")
                .resizable()
                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.25,
                       height:CGFloat(screenMeasurements.broadcastedWidth)*0.25,
                       alignment: .center)
                
              Earth(percent: percent)
                .stroke(Color("app_background"), lineWidth: CGFloat(screenMeasurements.broadcastedWidth))
                .rotationEffect(.degrees(360))

              .onAppear() {
                self.handleAnimations()
              }
              .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.15,
                     height: CGFloat(screenMeasurements.broadcastedWidth)*0.15,
                     alignment: .center)
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
    withAnimation(.easeIn(duration: uAnimationDuration)) {
      percent = 1
    }
  }
}

struct Earth: Shape {
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

