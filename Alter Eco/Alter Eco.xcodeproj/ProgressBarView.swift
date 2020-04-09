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
        
        VStack(spacing: CGFloat(screenMeasurements.broadcastedHeight / 23)) {
        
            // Display container for league information
            ZStack() {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth) * 0.9, height: CGFloat(screenMeasurements.broadcastedHeight) / 5)
                    .foregroundColor(Color("fill_colour"))
                VStack() {
                    HStack {
                        Text("You have reached league")
                        Image(systemName: retrieveLatestScore().league)
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(screenMeasurements.broadcastedHeight) / 20)
                    }
                    
                    // depending on which league user is in, display next one
                    if (userScore.league != "tortoise.fill") {
                        Text("Only \(POINTS_REQUIRED_FOR_NEXT_LEAGUE - retrieveLatestScore().totalPoints, specifier: "%.0f") points needed")
                        Text("to reach league \(getNewLeagueName(leagueName: getNewLeague(userLeague: userScore.league)))!")
                    }
                    else {
                        Text("You have reached the top league!")
                        Text("You are a true Alter Ecoer :)")
                    }
                    
                }
            }
                // Progress bar (stacked horizontally are current league icon coloured or not depending on how close user is to next league)
                HStack() {
                    ProgressBarIconView(iconNumber: ICON_ONE)
                    ProgressBarIconView(iconNumber: ICON_TWO)
                    ProgressBarIconView(iconNumber: ICON_THREE)
                    ProgressBarIconView(iconNumber: ICON_FOUR)
                    ProgressBarIconView(iconNumber: ICON_FIVE)
            }
        }
    }
}

struct ProgressBarIconView: View {
    
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    var iconNumber: Int
    
    init(iconNumber: Int) {
        self.iconNumber = iconNumber
    }
    
    var body: some View {
        HStack {
        Image(systemName: retrieveLatestScore().league)
            .resizable()
            .foregroundColor(getColor(iconNb: iconNumber))
            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.1, height: CGFloat(screenMeasurements.broadcastedHeight)/20)
        if (iconNumber < ICON_FIVE) {
        RoundedRectangle(cornerRadius: CGFloat(45.0)).frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.05, height: CGFloat(screenMeasurements.broadcastedHeight)/100)
                .opacity(1.0)
                .foregroundColor(Color("fill_colour"))
        }
        }
    }
}

