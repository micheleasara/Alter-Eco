import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    
    var body: some View {
        NavigationView() {
            ScrollView {
                Spacer()
                VStack{
                    ProfileImage()
                        .frame(height: screenMeasurements.longitudinal*0.37)
                    ScorePoints()
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    Text("Achievements")
                        .font(.title)
                        .fontWeight(.semibold)
                    AwardView()
                    Spacer(minLength: screenMeasurements.longitudinal*0.04)
                }
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ExplanationView())
            {
                Text("Info")
            })
        }

    }
}

struct AwardView: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    let SECONDS_WEEK = 604800.0
    let SECONDS_MONTH = 2592000.0
    let LONDON_AVG_CARBON_WEEK = 15.8

    var originalDate = Date() //setting current date as placeholder
    var timeInterval = 0.0
    
    var awardsList = [
        Awards(
            id: 0,
            name: "Bye-Flyer",
            description: "No airplane travel for 6 months",
            badgeTitle: "badge_plane",
            awarded: UserDefaults.standard.bool(forKey: String(0))
        ),
        Awards(
            id: 1,
            name: "Beating the Average",
            description: "Used less carbon than the London average for one week",
            badgeTitle: "badge_london",
            awarded: UserDefaults.standard.bool(forKey: String(1))
        ),
        Awards(
            id: 2,
            name: "Walker",
            description: "Walked more than 10 kms in a week",
            badgeTitle: "badge_feet",
            awarded: UserDefaults.standard.bool(forKey: String(2))
        ),
        Awards(
            id: 3,
            name: "No Wheels",
            description: "No car or bus travel for one month",
            badgeTitle: "badge_wheels",
            awarded: UserDefaults.standard.bool(forKey: String(3))
        ),
        Awards(
            id: 4,
            name: "Staying Inside for COVID-19",
            description: "Travelled less than 300m in a week",
            badgeTitle: "badge_crown",
            awarded: UserDefaults.standard.bool(forKey: String(4))
        ),
    ]
       
    init() {
        self.originalDate = try! DBMS.getFirstDate()
        ///Uncomment below to show some of the awards
        //self.originalDate = Date(timeIntervalSinceNow: -50000000 * 60)
        self.timeInterval = Date().timeIntervalSince(self.originalDate)

        if(try! DBMS.carbonWithinInterval(motionType:MeasuredActivity.MotionType.plane, from: Date(), interval: -183*60*60*24) == 0 && timeInterval > (SECONDS_MONTH*6))
        {
            UserDefaults.standard.set(true, forKey: String(0))
            awardsList[0].Awarded = UserDefaults.standard.bool(forKey: String(0))
        }
        
        if(try! DBMS.carbonWithinIntervalAll(from: Date(), interval: -7*60*60*24) < LONDON_AVG_CARBON_WEEK && timeInterval > SECONDS_WEEK)
        {
            UserDefaults.standard.set(true, forKey: String(1))
            awardsList[1].Awarded = UserDefaults.standard.bool(forKey: String(1))
        }
        
        if(try! DBMS.distanceWithinInterval(motionType: MeasuredActivity.MotionType.walking, from: Date(), interval: -7*60*60*24) > 10000 && timeInterval > SECONDS_WEEK)
        {
            UserDefaults.standard.set(true, forKey: String(2))
            awardsList[2].Awarded = UserDefaults.standard.bool(forKey: String(2))
        }
        
        if(try! DBMS.carbonWithinInterval(motionType: MeasuredActivity.MotionType.car, from: Date(), interval: -30*60*60*24) == 0 && timeInterval > SECONDS_MONTH)
        {
            UserDefaults.standard.set(true, forKey: String(3))
            awardsList[3].Awarded = UserDefaults.standard.bool(forKey: String(3))
        }
        
        if(try! DBMS.distanceWithinIntervalAll(from: Date(), interval: -30*60*60*24) < 300 && timeInterval > SECONDS_MONTH)
        {
            UserDefaults.standard.set(true, forKey: String(4))
            awardsList[4].Awarded = UserDefaults.standard.bool(forKey: String(4))
        }
    }
    
    var body: some View {
        ForEach(awardsList) { award in
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("fill_colour"))
                    .frame(width: self.screenMeasurements.trasversal*0.9, height: self.screenMeasurements.trasversal*0.35)
                HStack{
                    VStack{
                        Text(award.Name).font(.headline)

                        Text(award.Description).font(.caption)
                    }
                        .frame(width: self.screenMeasurements.trasversal*0.5, alignment: .center)
                        .padding(4)
                                   
                    Image(award.Awarded ? award.BadgeTitle : "badge_empty")
                        .frame(width: self.screenMeasurements.trasversal*0.22, height: self.screenMeasurements.trasversal*0.22, alignment: .center)
                        .scaleEffect(self.screenMeasurements.trasversal/1200)
                        .padding(4)
                }
            }
                .frame(width: self.screenMeasurements.trasversal*0.85, height: self.screenMeasurements.trasversal*0.4)
                .opacity(award.Awarded ? 1.0 : 0.6)
        }
    }
    
    func getMonth(dateArg: Date = Date()) -> String {
        let date = dateArg
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        return monthString
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
            if(savings.count != 0){
                ForEach(savings, id: \.self) { save in
                    VStack() {
                        Image(uiImage: UIImage(data: save.imageP ?? self.placeholder)!)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: self.screenMeasurements.trasversal*0.6, height: self.screenMeasurements.trasversal*0.6)
                            .shadow(radius: 10)
                    }
                }
                Button(action: {self.showingImagePicker = true}){
                    Circle()
                }
                    .foregroundColor(Color.white)
                    .opacity(0.01)
                    .frame(width: screenMeasurements.trasversal*0.41, height: screenMeasurements.trasversal*0.41)
            }
            
            Button(action: {self.showingImagePicker = true}){
                if(savings.count == 0){
                    Image("add_profile_pic")
                        .scaleEffect(screenMeasurements.longitudinal/1700)
                        .foregroundColor(Color("title_colour"))
                }
            }
                .background(Color("shadow"))
                .mask(Circle().scale(screenMeasurements.longitudinal/1000))
                    
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
                    ImagePicker(image: self.$inputImage)
                }
                
        }.frame(width: screenMeasurements.trasversal*0.6, height: screenMeasurements.longitudinal*0.3)
            
        NameView()
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return}
        if(savings.count != 0){
            self.moc.delete(savings[0])}
        let newPic = ProfilePic(context: self.moc)
        newPic.imageP = inputImage.jpegData(compressionQuality: CGFloat(1.0))
    }
}

struct ScorePoints: View {
    @State private var rect: CGRect = CGRect()
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @State private var showingInfo = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
               // .fill(Color("graphBars"))
                .fill(Color("fill_colour"))
                //.opacity(0.7)
                .frame(width: self.screenMeasurements.trasversal*0.9)
               // .overlay(
               //     RoundedRectangle(cornerRadius: 25, style: .continuous)
                //    .stroke(Color("graphBars"), lineWidth: 4)
               // )
                .padding(.horizontal, 10)
                .frame(height: screenMeasurements.longitudinal*0.1)
            HStack(alignment: .top){
                Text("Score:").font(.title) .fontWeight(.bold)
                Text("\((try! DBMS.retrieveLatestScore()).totalPoints, specifier: "%.0f")")
                    .font(.title)

            
            Button(action: {self.showingInfo = true}) {
                Image(systemName: "info.circle")
            }
                .alert(isPresented: $showingInfo) {
                    Alert(title: Text("Your Eco Score"), message: Text("We estimate your modes of transport throughout the day. Walking gets you 10 points, taking the tube 7 points, you only gain 3 points for taking the car and no points for plane travel!"), dismissButton: .default(Text("OK")))
                }
            }
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
                    self.changingNickname = false
                }.font(.callout)
                    .foregroundColor(Color("title_colour"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: screenMeasurements.trasversal*0.7)
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
