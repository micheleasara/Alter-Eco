//
//  ProgressBarView.swift
//  Alter Eco
//
//  Created by Virtual Machine on 02/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import Foundation
import SwiftUI

struct ProgressBarView: View {
    
    @Binding var value: Float
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    let userScore = retrieveScore(query: NSPredicate(format: "dateStr == %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    
    var body: some View {
        
        VStack(spacing: 10) {
        
            ZStack() {
                RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.95, height: CGFloat(self.screenMeasurements.broadcastedHeight)/6)
                    .foregroundColor(Color("fill_colour"))
                VStack(spacing: 10) {
                    HStack {
                        Text("You have reached league")
                        Image(systemName: userScore.league)
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    }
                    
                    if (userScore.league != "tortoise.fill") {
                        Text("Only \(1000 - userScore.totalPoints, specifier: "%.0f") points left to reach league \(getNewLeagueName(leagueName: getNewLeague(userStats: userScore)))!")
//                            .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    }
                    else {
                        Text("You have reached the top league in the game! You are a true Alter Ecoer :)")
                    }
                    Text("Congratulations!")
                }
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))

//                RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width:min(CGFloat(self.value)*CGFloat(self.screenMeasurements.broadcastedWidth)*0.9, CGFloat(self.screenMeasurements.broadcastedWidth)*0.9), height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
//
//                    .foregroundColor(Color(UIColor.systemBlue))
                
                HStack(spacing: 30) {
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/24)
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.09, height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.09, height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.09, height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
                    Circle().foregroundColor(Color(.white)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.09, height: CGFloat(self.screenMeasurements.broadcastedHeight)/25)
                }
                
                HStack(spacing: 30) {
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 1))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 2))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 3))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 4))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 5))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 6))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/23)
                }
            }
            .offset(x: CGFloat(self.screenMeasurements.broadcastedWidth)*0.001)
        }
    }
}
