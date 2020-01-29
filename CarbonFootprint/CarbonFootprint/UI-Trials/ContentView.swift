//
//  ContentView.swift
//  ThirdUIScreen
//
//  Created by Satisfaction on 26/01/2020.
//  Copyright © 2020 Satisfaction. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewRouter = ViewRouter()
    @State var showSplash = true
    
    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                VStack {
                        Spacer()
                        if (self.viewRouter.currentView == "home")
                        {
                            Text("Welcome back!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)

                        } else if (self.viewRouter.currentView == "profile") {
                            Text("Welcome to your profile")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.white)
                        }
                        Spacer()

                        HStack {
                            Image(systemName: "house")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(20)
                                .frame(width: geometry.size.width/3, height: 75, alignment: .leading)
                                .foregroundColor(self.viewRouter.currentView == "home" ? .black : .gray)
                                .onTapGesture {
                                    self.viewRouter.currentView = "home"
                            }
                            Image(systemName: "gear")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(20)
                                .frame(width: geometry.size.width/3, height: 75, alignment:.trailing)
                                .foregroundColor(self.viewRouter.currentView == "profile" ? .black : .gray)
                                .onTapGesture {
                                    self.viewRouter.currentView = "profile"
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height/10)
                        .background(Color.white.shadow(radius: 3))
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
                Color.black.edgesIgnoringSafeArea(.all)
            
//                SplashScreen()
//                    .opacity(self.showSplash ? 1 : 0)
//                    .onAppear {DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                        SplashScreen.shouldAnimate = false
//                        withAnimation() {
//                            self.showSplash = false
//                            }
//                        }
//                    }
                
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//----------- Test 2 -------------
//        VStack(alignment: .leading) {
//            Text("Carbon Comparison")
//                .font(.title)
//                .fontWeight(.semibold)
//                //.multilineTextAlignment(.leading)
//            //Divider()
//            Text("Compare your performance with others!")
//                .font(.subheadline)
//                .fontWeight(.regular)
//                //.multilineTextAlignment(.leading)
//
//        }
//        //.edgesIgnoringSafeArea(.top)
//        .offset(y: -350)
//        .padding(.leading, -60)

//----------- Test 1 -------------
//              .background(Color.black)

//        VStack {
//            Color.black
//            MapView()
//                .frame(height: 300)
//                .edgesIgnoringSafeArea(.top)
//
//            CircleImage()
//                .offset(y: -130)
//                .padding(.bottom, -130)
//
//            VStack() {
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                        .foregroundColor(Color.black)
//                .multilineTextAlignment(.center)
//                    //HStack {
//                HStack {
//                    Text("National Park")
//                        .font(.subheadline)
//                    Spacer()
//                    Text("Paris")
//                        .font(.subheadline)
//                    }
//
//            }
//            .padding()
//        }
//    }
