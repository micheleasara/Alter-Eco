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

    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    let userScore = retrieveScore(query: NSPredicate(format: "dateStr == %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    
    
    var body: some View {
        
        VStack(spacing: CGFloat(self.screenMeasurements.broadcastedHeight / 25)) {
        
            ZStack() {
                RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.95, height: CGFloat(self.screenMeasurements.broadcastedHeight)/5.5)
                    .foregroundColor(Color("fill_colour"))
                VStack() {
                    HStack {
                        Text("You have reached league")
                        Image(systemName: userScore.league)
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight) / 20)
                    }
                    
                    if (userScore.league != "tortoise.fill") {
                        Text("Only \(1000 - userScore.totalPoints, specifier: "%.0f") points left to reach league \(getNewLeagueName(leagueName: getNewLeague(userStats: userScore)))!")
                        Text("Congratulations!")
                    }
                    else {
                        Text("You have reached the top league!")
                        Text("You are a true Alter Ecoer :)")
                    }
                    
                }
            }

                HStack() {
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 1))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 2))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 3))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 4))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: userScore.league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: 5))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
            }
        }
    }
}
