//
//  ContentView.swift
//  TrackerGraphs2UI
//
//  Created by e withnell on 19/01/2020.
//  Copyright © 2020 e withnell. All rights reserved.
//

import SwiftUI

//import a struct here?

struct DayDataPoint: Identifiable {
    let id = UUID()
    let transportmode: String
    let value: CGFloat
}



//let dayInfo = ["Walking": 1,"Running": 2,"Car": 3,"Bike": 4,"Unknown": 5]

struct DetailView: View {
//transport mode and value to be pulled from the database!
//if the number of transport modes changes then the HStack below needs to change
    static let data: [DayDataPoint] = [
    .init(transportmode: "Walking", value: 0.6),
    .init(transportmode: "Running", value: 0.4),
    .init(transportmode: "Car", value: 0.8),
    .init(transportmode: "Bike", value: 0.7),
    .init(transportmode: "Bike", value: 0.7),
     ]
    
    static let eveningData: [DayDataPoint] = [
        .init(transportmode: "One", value: 0.9),
        .init(transportmode: "Two", value: 0.4),
        .init(transportmode: "Three", value: 0.3),
        .init(transportmode: "Four", value: 0.3),
        .init(transportmode: "x", value: 0.3),
 
    ]
    static let afternoonData: [DayDataPoint] = [
             .init(transportmode: "Walking", value: 0.6),
             .init(transportmode: "Running", value: 0.4),
             .init(transportmode: "Car", value: 0.8),
             .init(transportmode: "Bike", value: 0.7),
             .init(transportmode: "Unknown", value: 0.4),
      ]
    @State var dataSet = [
        data, afternoonData, eveningData
    ]
    
    var spacing: CGFloat = 24
    
    @State var selectedTime = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("appBackground")
                    .edgesIgnoringSafeArea(.all)
                VStack (spacing: 16) {
                    Spacer()
                    Text("Carbon Consumed")
                        .font(.system(size: 32))
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 0)
                    
                    Picker(selection: self.$selectedTime, label: Text("XXX")) {
                        Text("Daily").tag(0)
                        Text("Weekly").tag(1)
                        Text("Monthly").tag(2)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    HStack (spacing: self.spacing) {
                        // WARNING: Don't use a ForEach here, it doesn't animate.
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][0], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][1], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][2], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][3], width: (geometry.size.width - 6 * self.spacing) / 5)
                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][4], width: (geometry.size.width - 6 * self.spacing) / 5)
//                        StackedBarView(dataPoint: self.dataSet[self.selectedTime][5], width: (geometry.size.width - 7 * self.spacing) / 6)
//                      //  StackedBarView(dataPoint: self.dataSet[self.selectedTime][6], width: (geometry.size.width - 8 * self.spacing) / 6)
                    }.animation(.default)
                    Spacer()
                }
            }
        }
    }
}

struct StackedBarView: View {
    var dataPoint: DayDataPoint
    var width: CGFloat
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                Capsule()
                    .frame(width: width, height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color(.sRGB, red: 74/255, green: 231/255, blue: 184/255)))
                Capsule()
                    .frame(width: width, height: dataPoint.value * 200)
                    .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                
            }.padding(.bottom, 8)
            Text(dataPoint.transportmode)
                .font(.system(size: 14))
        }
        
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .trailing)
            .combined(with: .opacity)
        let removal = AnyTransition.scale
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
