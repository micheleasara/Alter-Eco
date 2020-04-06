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

    var userScore = retrieveLatestScore()
    
    var body: some View {
        
        VStack(spacing: CGFloat(self.screenMeasurements.broadcastedHeight / 25)) {
        
            // Display container for league information
            ZStack() {
                RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.95, height: CGFloat(self.screenMeasurements.broadcastedHeight)/5.5)
                    .foregroundColor(Color("fill_colour"))
                VStack() {
                    HStack {
                        Text("You have reached league")
                        Image(systemName: retrieveLatestScore().league)
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight) / 20)
                    }
                    
                    // depending on which league user is in, display next one
                    if (userScore.league != "tortoise.fill") {
                        Text("Only \(POINTS_REQUIRED_FOR_NEXT_LEAGUE - retrieveLatestScore().totalPoints, specifier: "%.0f") points left to reach league \(getNewLeagueName(leagueName: getNewLeague(userLeague: userScore.league)))!")
                        Text("Congratulations!")
                    }
                    else {
                        Text("You have reached the top league!")
                        Text("You are a true Alter Ecoer :)")
                    }
                    
                }
            }
                // Progress bar (stacked horizontally are current league icon coloured or not depending on how close user is to next league)
                HStack() {
                    Image(systemName: retrieveLatestScore().league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: ICON_ONE))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: retrieveLatestScore().league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: ICON_TWO))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: retrieveLatestScore().league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: ICON_THREE))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: retrieveLatestScore().league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: ICON_FOUR))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
                    RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(self.screenMeasurements.broadcastedHeight)/100)
                        .opacity(1.0)
                        .foregroundColor(Color("fill_colour"))
                    Image(systemName: retrieveLatestScore().league)
                        .resizable()
                        .foregroundColor(getColor(iconNb: ICON_FIVE))
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(self.screenMeasurements.broadcastedHeight)/20)
            }
        }
    }
}

