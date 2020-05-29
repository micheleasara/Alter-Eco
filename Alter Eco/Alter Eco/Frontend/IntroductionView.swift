//
//  IntroductionView.swift
//  Alter Eco
//
//  Created by Deli De leon de miguel on 29/05/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import SwiftUI

struct IntroductionView: View {
    var body: some View {
        VStack {
            Text("Welcome to Alter Eco!")
                .font(Font.title)
                .bold()
                .padding(.top)
            
            Image("earth").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            basicInformation.padding()
        }
    }
    
    var basicInformation: some View {
        ScrollView {
            VStack (alignment:.leading) {
                Text("What is this app about?").bold()
                Text("Alter Eco is a way for you to track your carbon dioxide production.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("How does it work?").bold()
                Text("By using the GPS, the software tries to determine what kind of transportation you take and computes the carbon associated with it.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("What about my privacy?").bold()
                Text("Your data is stored only on your device. If you want to erase it, simply delete the app. Plus, no information about the exact locations you visited is ever recorded.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)
                
                Text("What about my battery?").bold()
                Text("Alter Eco tries to minimize its battery impact by stopping the tracking when appropriate. Of course, you are always free to pause or resume it whenever you want!")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}
