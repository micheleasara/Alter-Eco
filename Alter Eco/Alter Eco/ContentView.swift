//
//  View2.swift
//  TrackerGraphs2UI
//
//  Created by e withnell on 19/01/2020.
//  Copyright © 2020 e withnell. All rights reserved.
//

// This is to try and commit

//import Foundation
import SwiftUI
//MAX'S HOMESCREEN

import MapKit

struct ContentView: View {
  @State var showSplash = true
  
  var body: some View {
    ZStack{
      
          DetailView()
      SplashScreen()
        .opacity(showSplash ? 1 : 0)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         
     
          //  MapView(coordinate: CLLocationCoordinate2DMake(37.331820, -122.03118))
            //    .edgesIgnoringSafeArea(.all)
            SplashScreen.shouldAnimate = false
            withAnimation() {
              self.showSplash = false
           
            }
            
          }
            
      }
        
    }
    
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif


//                SplashScreen()
//                    .opacity(self.showSplash ? 1 : 0)
//                    .onAppear {DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                        SplashScreen.shouldAnimate = false
//                        withAnimation() {
//                            self.showSplash = false
//                            }
//                        }
//                    }
                
//        }
  //  }
//}


//struct ContentView_Previews: PreviewProvider {
  //  static var previews: some View {
    //    ContentView()
    //}
//}























//PREVIOUS BUTTON HOME SCREEN:

//struct ContentView: View {
//
//    @State private var isActive: Bool=false
//    @State private var selection: Int? = nil
//
//    var body: some View {
//
//        NavigationView {
//
//      VStack {
//                NavigationLink(destination: DetailView(), tag: 1, selection: self.$selection) {
//                    Text("")
//                }
//
//                Button("Woo it's the Carbon Tracker!")
//                {
//                self.selection=1
//            }
//    }
//    }
//}
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

