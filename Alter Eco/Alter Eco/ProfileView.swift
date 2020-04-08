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
    var currentDate = Date()
    let formatter = DateFormatter()

    var originalDate = Date()
    var currentYear = 2020
    var currentMonth = ""
    var currentWeek = ""
    var currentDay = 0
       
    var notUsedCarPastMonth = false
    var notUsedPlanePastMonth = false
    let weeklyLondonAverageKg = 15.8
    var lowerThanAverage = false
    var walkingMoreThan = false
       
       
    var longerThanWeek = false
    var longerThanMonth = false
    var longerThanYear = false
       
    var timeInterval = 0.0
       
    init() {
        self.currentMonth = getMonth()
        self.currentDay = getDay()
        self.currentYear = getYear()

        
        self.originalDate = getFirstDate()
        //Uncomment below to show some of the awards
        //self.originalDate = Date(timeIntervalSinceNow: -50000000 * 60)

        self.timeInterval = currentDate.timeIntervalSince(self.originalDate)
           
        if(timeInterval > 604800)
        {longerThanWeek = true}
           
        if(timeInterval > 2592000)
        {longerThanMonth = true}
           
        if(timeInterval > 31536000)
        {longerThanYear = true}
           
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.car, month: currentMonth) == 0 && longerThanMonth)
        {
            self.notUsedCarPastMonth = true
        }
           
        if(queryPastMonth(motionType:MeasuredActivity.MotionType.plane, month: currentMonth) == 0 && longerThanMonth)
        {
            self.notUsedPlanePastMonth = true
        }
           
        if(queryTotalWeek() < weeklyLondonAverageKg && longerThanWeek)
        {
            lowerThanAverage = true
        }
           
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.walking, month: currentMonth, carbon: false) > 1000 && longerThanMonth)
        {
            walkingMoreThan = true
        }

    }
    
    var body: some View {
        ScrollView {
            Spacer()
            VStack{
                ProfileImage()
                    .frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.37)
                ScorePoints()
                Divider()
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                AchievementsTitle()
                VStack{
                    if(notUsedPlanePastMonth == true){
                        ZStack{
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(Color("fill_colour"))
                                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedWidth)*0.35)
                            HStack{
                                VStack{
                                    Text("Bye Flyer").font(.headline)

                                    Text("No airplane travel for 1 entire year").font(.caption)
                                }
                                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.5, alignment: .center)
                                    .padding(4)
                
                                    Image("badge_plane")
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.22, height: CGFloat(screenMeasurements.broadcastedWidth)*0.22, alignment: .center)
                                        .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/600)
                                        .padding(4)
                            }
                        }
                            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.85, height: CGFloat(screenMeasurements.broadcastedWidth)*0.4)
                    }
                    if(lowerThanAverage == true){
                        ZStack{
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(Color("fill_colour"))
                                .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedWidth)*0.35)
                            HStack{
                                VStack{
                                    Text("Beating the Average").font(.headline)

                                    Text("Used less carbon than the London average for one week").font(.caption)
                                }
                                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.5, alignment: .center)
                                    .padding(4)
                                
                                Image("badge_london")
                                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.22, height: CGFloat(screenMeasurements.broadcastedWidth)*0.22, alignment: .center)
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/600)
                                    .padding(4)
                            }
                        }
                            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.85, height: CGFloat(screenMeasurements.broadcastedWidth)*0.4)
                    }
                    if(walkingMoreThan == true)
                    {
                        ZStack{
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                  .fill(Color("fill_colour"))
                                  .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedWidth)*0.35)
                            HStack{
                                VStack() {
                                    Text("Walker").font(.headline)
                                    //.padding(.horizontal, 10)

                                    Text("Walked more than 1000 kms in a week").font(.caption)
                                }
                                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.5, alignment: .center)
                                    .padding(4)
                                
                                Image("badge_feet")
                                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.22, height: CGFloat(screenMeasurements.broadcastedWidth)*0.22, alignment: .center)
                                    .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/600)
                                    .padding(4)
                            }
                        }
                            .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.85, height: CGFloat(screenMeasurements.broadcastedWidth)*0.4)
                    }
                    if(notUsedCarPastMonth == true){
                        ZStack{
                             RoundedRectangle(cornerRadius: 25, style: .continuous)
                                 .fill(Color("fill_colour"))
                                 .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(screenMeasurements.broadcastedWidth)*0.35)
                            
                                HStack{
                                    VStack(alignment: .center) {
                                        Text("No Wheels").font(.headline)

                                        Text("No car or bus travel for one week").font(.caption)
                                    }
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.5, alignment: .center)
                                        .padding(4)

                                    Image("badge_wheels")
                                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.22, height: CGFloat(screenMeasurements.broadcastedWidth)*0.22, alignment: .center)
                                        .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/600)
                                        .padding(4)
                             }
    
                        }
                             .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.85, height: CGFloat(screenMeasurements.broadcastedWidth)*0.4)
                    }
                    Spacer()
                    if(!notUsedCarPastMonth && !notUsedPlanePastMonth && !walkingMoreThan && !lowerThanAverage){
                        Text("No awards yet! Try cutting down on your carbon footprint by avoiding car and plane travel and walking more.")
                        .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.85)
                            .foregroundColor(Color("minor_text"))
                    }
                }
            }
        }
    }
    
    func getYear(dateArg: Date = Date()) -> Int {
        let date = dateArg
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let currentYear = components.year
        return currentYear!
    }
    
    func getMonth(dateArg: Date = Date()) -> String {
        let date = dateArg
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        return monthString
    }
    
    func getDay(dateArg: Date = Date()) -> Int {
        let date = dateArg
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        let dayOfMonth = components.day
        return dayOfMonth!
    }
    
}

struct ProfileImage: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State var placeholder : Data = .init(count: 0)
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: ProfilePic.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \ProfilePic.imageP, ascending: true)
        ]
    ) var savings : FetchedResults<ProfilePic>
    
    var body: some View {
        VStack(spacing: 0){
        ZStack{
            //VStack{
                if(savings.count != 0){
                    ForEach(savings, id: \.self) { save in
                       VStack() {
                    Image(uiImage: UIImage(data: save.imageP ?? self.placeholder)!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.6, height: CGFloat(self.screenMeasurements.broadcastedWidth)*0.6)
                        .shadow(radius: 10)
                    }
                    }
                    Button(action: {self.showingImagePicker = true}){
                        Circle()
                    }
                    .foregroundColor(Color.white)
                    .opacity(0.01)
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.41, height: CGFloat(screenMeasurements.broadcastedWidth)*0.41)
               }
            
                Button(action: {self.showingImagePicker = true}){
                    if(savings.count == 0){
                    Image("add_profile_pic")
                        .scaleEffect(CGFloat(screenMeasurements.broadcastedHeight)/1700)
                        .foregroundColor(Color("title_colour"))
                    }
                }
                .background(Color("shadow"))
                .mask(Circle().scale(CGFloat(screenMeasurements.broadcastedHeight)/1000))
                    
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                    ImagePicker(image: self.$inputImage)
                }
                
        }.frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.6, height: CGFloat(screenMeasurements.broadcastedHeight)*0.3)
            
            NameView()
        }
    }
    
    func loadImage() {
        //guard let inputImage = inputImage else { return}
        if(savings.count != 0){
            self.moc.delete(savings[0])}
        let newPic = ProfilePic(context: self.moc)
        newPic.imageP = self.inputImage?.pngData()
    }
}

struct ScorePoints: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    let userScore = retrieveLatestScore()
    
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
                Text("\(userScore.totalPoints, specifier: "%.0f")")
                    .font(.title)
            }
        }
    }
}

struct AchievementsTitle: View {
@State private var rect: CGRect = CGRect()
@EnvironmentObject var screenMeasurements: ScreenMeasurements
    var body: some View {
        HStack{
            /*Image("trophy")
                .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/2000)
                .frame(width: 50, height: 50)*/
            Text("Achievements")
                .font(.title)
                .fontWeight(.semibold)
            /*Image("trophy")
                .scaleEffect(CGFloat(screenMeasurements.broadcastedWidth)/2000)
                .frame(width: 50, height: 50)*/
        }
    }
}

struct NameView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State var name: String = ""
    @State var nickname: String = UserDefaults.standard.string(forKey: "Nickname") ?? ""
    @State private var changingNickname = false

    var body: some View {
        VStack {
            if(nickname == "" || changingNickname == true)
            {
                TextField(" Enter Your Nickname", text: $name){
                    self.addNickname()
                    UIApplication.shared.keyWindow?.endEditing(true)
                    self.changingNickname = false
                }.font(.callout)
                    .foregroundColor(Color("title_colour"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: CGFloat(screenMeasurements.broadcastedWidth)*0.7)
            }
            else
            {
                VStack{
                    Text("Hello \(nickname)!")
                        .layoutPriority(1.0)
                    Button(action: {self.changingNickname = true}){
                        Text("Change nickname")
                        }.font(.body)
                }
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
