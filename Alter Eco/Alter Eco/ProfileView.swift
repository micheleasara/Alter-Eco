//
//  ProfileView.swift
//  Alter Eco
//
//  Created by Hannah Kay on 01/03/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    let currentDate = Date()
    var currentMonth = ""
    var currentWeek = ""
    var currentDay = 0
    var usedCarPastMonth = true
    var usedPlanePastMonth = true
    let weeklyLondonAverageKg = 15.8
    var lowerThanAverage = false
    var walkingMoreThan = false
    
    init() {
        self.currentMonth = getCurrentMonth()
        self.currentDay = getCurrentDay()
        
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.car, month: currentMonth) == 0)
        {
            self.usedCarPastMonth = false
        }
        
        /*if(queryPastMonth(motionType:MeasuredActivity.MotionType.plane, month: currentMonth) == 0)
        {
            self.usedPlanePastMonth = false
        }*/ //can uncomment when we have plane as travel type
        
        if(queryTotalWeek() < weeklyLondonAverageKg)
        {
            lowerThanAverage = true
        }
        
        print("Walking the talk man")
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.walking, month: currentMonth, carbon: false) > 100)
        {
            walkingMoreThan = true
        }

    }

    var body: some View {
       //NavigationView {
        ScrollView {
            VStack{
                ProfileImage()
                ScorePoints()
                Divider()
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                HStack{
                    Image("trophy")
                        .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/2000)
                        .frame(width: 50, height: 50)
                    Text("Achievements").font(.title)
                    Image("trophy")
                        .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/2000)
                        .frame(width: 50, height: 50)
                }
                VStack{
                    if(usedPlanePastMonth == false){
                        ZStack{
                            RectangleView()
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("Bye Flyer").font(.headline)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                    Text("No airplane travel for 1 year").font(.body)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                }
                                Image("medal (2)")
                                    
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/1000)
                                    .shadow(color: Color("shadow"), radius: 8, x: 10, y: 0)
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                    if(lowerThanAverage == true){
                        ZStack{
                            RectangleView()
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("Beating the Average").font(.headline)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                    Text("Used less carbon than the UK average for one week").font(.body)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                }
                                Image("medal (1)")
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/1000)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("shadow"), radius: 8, x: 0, y: 0)

                            }
                        }
                    }
                    if(walkingMoreThan == true)
                    {
                        ZStack{
                            RectangleView()
                            HStack{
                                VStack(alignment: .leading) {
                                    Text("Get Low").font(.headline)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                    Text("Lowered your own carbon footprint for 2 weeks in a row").font(.body)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                }
                                Image("medal (3)")
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/1500)
                                    .shadow(color: Color("shadow"), radius: 8, x: 0, y: 0)
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                    if(usedCarPastMonth == false){
                        ZStack{
                             RectangleView()
                             HStack{
                                 VStack(alignment: .leading) {
                                     Text("No Wheels").font(.headline)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                    Text("No car or bus travel for 1 week").font(.body)
                                        .padding(.horizontal, 10)
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, alignment: .leading)
                                 }
                                 Image("no_medal")
                                    .colorMultiply(Color("secondary_label"))
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/1000)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color("shadow"), radius: 8, x: 0, y: 0)
                             }
                        }
                    }
                }
            }
            }
        //.navigationBarTitle("Profile")
        //}
    }
    
    func getCurrentMonth() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        return monthString
    }
    
    func getCurrentDay() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        let dayOfMonth = components.day
        return dayOfMonth!
    }
    

}

struct AwardView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    var body: some View {
    
        Text("Hello")
    }
}

struct RectangleView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    var body: some View {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color("fill_colour"))
            //.stroke(Color("Gold"), lineWidth: 4)
            .padding(.bottom, 15)
            .padding(.horizontal, 10)
            .frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.2)
        
    }
}

struct ProfileImage: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("fill_colour"))
                .padding(.bottom, 20)
                .padding(.horizontal, CGFloat(10))
                .padding(.top, 30)
                //.frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.3)
            VStack{
                if(inputImage != nil){
                image?
                    .resizable()
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .padding(.bottom, 15)
                    .frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.17)
                    .scaledToFit()
                }
                Button(action: {self.showingImagePicker = true}){
                    if(inputImage == nil){
                    Image("add_profile_pic")
                        .scaleEffect(0.4)
                        .foregroundColor(Color("title_colour"))
                    }
                }
                .background(Color("shadow"))
                .mask(Circle().scale(0.7))
                    
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                    ImagePicker(image: self.$inputImage)
                    }
                
                NameView()
            }

        }.frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.33)


    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return}
        image = Image(uiImage: inputImage)
    }
}

struct ScorePoints: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    let userScore = retrieveScore(query: NSPredicate(format: "dateStr == %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("graphBars"))
                .opacity(0.7)
                .overlay(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(Color("graphBars"), lineWidth: 4)
                )
                .padding(.horizontal, 10)
                .frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.1)
            HStack(alignment: .top){
                Text("Score:").font(.title) .fontWeight(.bold)
                Text("\(updateScore(score: userScore).totalPoints, specifier: "%.0f")")
                    .font(.title)
            }
        }
    }
}

struct NameView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State var name: String = ""
    @State var nickname: String = UserDefaults.standard.string(forKey: "Nickname") ?? ""
    var body: some View {
        VStack {
            if(nickname == "")
            {
                TextField(" Enter Your Nickname", text: $name){
                    self.addNickname()
                    UIApplication.shared.keyWindow?.endEditing(true)
                }
                    .foregroundColor(Color("title_colour"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7)
            }
            else
            {
                Text("Hello \(nickname)!")
            }
        }
        .font(.title)
    }
    
    func addNickname() {
        self.nickname = name
        UserDefaults.standard.set(self.nickname, forKey: "Nickname")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
            NameView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
    }
}
