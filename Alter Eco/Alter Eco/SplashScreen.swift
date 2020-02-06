//
//  splashscreen.swift
//  TrackerGraphs2UI
//
//  Created by e withnell on 29/01/2020.
//  Copyright © 2020 e withnell. All rights reserved.
//

import Foundation


import SwiftUI

struct SplashScreen: View {
    let fuberBlue = Color("Alter Eco")
    
    @State var percent = 0.0
    let uLineWidth: CGFloat = 5
    
    @State var uScale: CGFloat = 3
    let uZoomFactor: CGFloat = 1.4
    
    @State var squareColor = Color.white
    @State var squareScale: CGFloat = 1
    
    let uSquareLength: CGFloat = 12
    
    @State var lineScale: CGFloat = 1
    
    @State var textAlpha = 0.0
    @State var textScale: CGFloat = 1
    
    static var shouldAnimate = true
    
    var body: some View {
        ZStack {
            Image("Chimes")
                .resizable(resizingMode: .tile)
                .opacity(textAlpha)
                .scaleEffect(textScale)
            
            
            Text("Alter Ec")
                .font(.largeTitle)
                .foregroundColor(.white)
                .opacity(textAlpha)
                .scaleEffect(textScale)
                .offset(x: -19, y: 0)
            
            FuberU(percent: percent)
                
                .stroke(Color.white, lineWidth: uLineWidth)
                .rotationEffect(.degrees(-90))
                .offset(x: 19, y: 0)
                .aspectRatio(1, contentMode: .fit)
                .padding(20)
                
                .onAppear() {
                    self.handleAnimations()
            }
            .scaleEffect(uScale * uZoomFactor)
            .frame(width: 45, height: 45, alignment: .center)
            
//            Rectangle()
//                //.offset(x: 50, y: 0)
//                .fill(squareColor)
//                .scaleEffect(squareScale * uZoomFactor)
//                
//                .frame(width: uSquareLength, height: uSquareLength, alignment: .center)
//                .onAppear() {
//                    self.squareColor = self.fuberBlue
//            }
//            
            Spacer()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

extension SplashScreen {
    var uAnimationDuration: Double { return 1.0 }
    var uAnimationDelay: Double { return  0.2 }
    var uExitAnimationDuration: Double{ return 0.3}
    var finalAnimationDuration: Double { return 0.6 }
    var minAnimationInterval: Double { return 0.1 }
    var fadeAnimationDuration: Double { return 0.0 }
    
    func handleAnimations() {
        runAnimationPart1()
        //        runAnimationPart2()
        //        runAnimationPart3()
        if SplashScreen.shouldAnimate {
            restartAnimation()
        }
    }
    
    func runAnimationPart1() {
        withAnimation(.easeIn(duration: uAnimationDuration)) {
            percent = 1
            uScale = 3
            //lineScale = 1
        }
        
        withAnimation(Animation.easeIn(duration: uAnimationDuration).delay(0.5)) {
            textAlpha = 1.0
        }
        
        //        let deadline: DispatchTime = .now() + uAnimationDuration + uAnimationDelay
        //        DispatchQueue.main.asyncAfter(deadline: deadline) {
        //            withAnimation(.easeOut(duration: self.uExitAnimationDuration)) {
        //                self.uScale = 0
        //                self.lineScale = 0
        //            }
        //            withAnimation(.easeOut(duration: self.minAnimationInterval)) {
        //                self.squareScale = 0
        //            }
        //
        withAnimation(Animation.spring()) {
            self.textScale = self.uZoomFactor
        }
        //        }
    }
    //    func runAnimationPart2() {
    //        let deadline: DispatchTime = .now() + uAnimationDuration +
    //            uAnimationDelay + minAnimationInterval
    //        DispatchQueue.main.asyncAfter(deadline: deadline) {
    //            self.squareColor = Color.white
    //            self.squareScale = 1
    //        }
    //    }
    //    func runAnimationPart3() {
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2 * uAnimationDuration) {
    //            withAnimation(.easeIn(duration: self.finalAnimationDuration)) {
    //                //TODO: Add code #3 for text here
    //                self.squareColor = self.fuberBlue
    //            }
    //        }
    //    }
    func restartAnimation() {
        let deadline: DispatchTime = .now() + 2 * uAnimationDuration +
        finalAnimationDuration
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.percent = 0
            //TODO: Add code #4 for text here
            self.handleAnimations()
        }
    }
}

struct FuberU: Shape {
    var percent: Double
    
    // 1
    func path(in rect: CGRect) -> Path {
        let end = percent * 360
        var p = Path()
        
        // 2
        p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
                 radius: rect.size.width/2,
                 startAngle: Angle(degrees: 0),
                 endAngle: Angle(degrees: end),
                 clockwise: false)
        
        return p
    }
    // 3
    var animatableData: Double {
        get { return percent }
        set { percent = newValue }
    }
}


#if DEBUG
struct SplashScreen_Previews : PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
#endif
