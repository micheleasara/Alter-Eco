import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                    ProfileImage()
                        .frame(height: 0.5*screenMeasurements.trasversal)
                        .padding(.bottom).padding(.top)
                NameView().padding(.bottom)
                    ScorePoints().frame(height: screenMeasurements.trasversal/7)
                    Divider()
                        .padding()
                    Text("Achievements")
                        .font(.title)
                        .fontWeight(.semibold)
                    AwardView()
            }.padding(.horizontal)
        }
    }
}

struct ProfileImage: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = ProfileImage.loadStoredImage()
    
    static func loadStoredImage() -> UIImage? {
        let results = try? DBMS.executeQuery(entity: "ProfilePic", predicate: nil, args: nil) as? [NSManagedObject]
        if let results = results {
            if results.count > 0 {
                return UIImage(data: results[0].value(forKey: "imageP")! as! Data)
            }
        }
        
        // if not found
        return nil
    }
    
    var body: some View {
        GeometryReader { geo in
            Group {
                if self.inputImage != nil {
                    self.resizeImageToFitHeight(image: self.inputImage!, height: geo.size.height).clipShape(Circle())
                } else {
                    self.resizeImageToFitHeight(image: UIImage(named: "add_profile_pic")!, height: 0.65*geo.size.height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .sheet(isPresented: self.$showingImagePicker) {
                ImagePicker(onCompletionCallback: self.imageSelectionCompleted(image:)) }
            .onTapGesture {
                self.showingImagePicker = true
            }
        }
    }
    
    func imageSelectionCompleted(image: UIImage?) {
        if let img = image {
            clearDBAndStoreImage(inputImage: img)
            inputImage = img
        }
    }
    
    func resizeImageToFitHeight(image: UIImage, height: CGFloat) -> some View {
        let widthToHeight = image.size.width / image.size.height
        let width = widthToHeight * height
        let fit = Image(uiImage: image).resizable()
        return fit.frame(width: width, height: height)
    }
    
    func clearDBAndStoreImage(inputImage: UIImage) {
        try? DBMS.deleteAll(entity: "ProfilePic")
        if let newPic = inputImage.jpegData(compressionQuality: CGFloat(1.0)) {
            try? DBMS.setValuesForKeys(entity: "ProfilePic", keyedValues: ["imageP":newPic])
        }
    }
}

struct ScorePoints: View {
    @State private var showingInfo = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("fill_colour"))
            HStack(alignment: .center){
                Text("Current score: ").font(.title)
                + Text("\((try! DBMS.retrieveLatestScore()).totalPoints, specifier: "%.0f")")
                    .font(.title)

            
            Button(action: {self.showingInfo = true}) {
                Image(systemName: "info.circle")
            }
                .alert(isPresented: $showingInfo) {
                    Alert(title: Text("Your Eco Score"), message: Text("We estimate your modes of transport throughout the day. The more eco-friendly your commute is, the more points you earn!"), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

struct NameView: View {
    @State var name: String = ""
    @State var nickname: String = UserDefaults.standard.string(forKey: "Nickname") ?? ""
    @State private var changingNickname = false

    var body: some View {
        VStack {
            if(nickname == "" || changingNickname) {
                enterNicknameTextField
            }
            else {
                greetingWithChangeButton
            }
        }
    }
    
    var enterNicknameTextField: some View {
        TextField(" Enter Your Nickname", text: $name) {
            self.addNickname()
            self.changingNickname = false
        }
            .font(.callout)
            .foregroundColor(Color.secondary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    var greetingWithChangeButton: some View {
        VStack {
            Text("Hello \(nickname)!")
                .foregroundColor(Color.primary)
            Button(action: {
                self.changingNickname = true
            }) { Text("Change nickname").font(.body)}
        }
    }
    
    func addNickname() {
        self.nickname = name
        UserDefaults.standard.set(self.nickname, forKey: "Nickname")
    }
}


struct AwardView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements

    var originalDate = (try? DBMS.getFirstDate()) ?? Date().toLocalTime()
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
        // Uncomment below to show some of the awards
        //self.originalDate = Date(timeIntervalSinceNow: -50000000 * 60)
        self.timeInterval = Date().toLocalTime().timeIntervalSince(self.originalDate)

        if (try! DBMS.carbonWithinInterval(motionType:MeasuredActivity.MotionType.plane, from: Date().toLocalTime(), interval: -183*DAY_IN_SECONDS) == 0 && timeInterval > (30*DAY_IN_SECONDS*6))
        {
            UserDefaults.standard.set(true, forKey: String(0))
            awardsList[0].Awarded = UserDefaults.standard.bool(forKey: String(0))
        }
        
        if (try! DBMS.carbonFromPollutingMotions(from: Date().toLocalTime(), interval: -WEEK_IN_SECONDS) < LONDON_AVG_CARBON_WEEK && timeInterval > WEEK_IN_SECONDS)
        {
            UserDefaults.standard.set(true, forKey: String(1))
            awardsList[1].Awarded = UserDefaults.standard.bool(forKey: String(1))
        }
        
        if (try! DBMS.distanceWithinInterval(motionType: MeasuredActivity.MotionType.walking, from: Date().toLocalTime(), interval: -WEEK_IN_SECONDS) > 10000 && timeInterval > WEEK_IN_SECONDS)
        {
            UserDefaults.standard.set(true, forKey: String(2))
            awardsList[2].Awarded = UserDefaults.standard.bool(forKey: String(2))
        }
        
        if (try! DBMS.carbonWithinInterval(motionType: MeasuredActivity.MotionType.car, from: Date().toLocalTime(), interval: -30*DAY_IN_SECONDS) == 0 && timeInterval > 30*DAY_IN_SECONDS)
        {
            UserDefaults.standard.set(true, forKey: String(3))
            awardsList[3].Awarded = UserDefaults.standard.bool(forKey: String(3))
        }
        
        if (try! DBMS.distanceWithinIntervalAll(from: Date().toLocalTime(), interval: -30*DAY_IN_SECONDS) < 300 && timeInterval > 30*DAY_IN_SECONDS)
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
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            ProfileView()
            ProfileImage()
            ScorePoints()
            NameView()
            VStack {
                AwardView()
            }
        }.environmentObject(ScreenMeasurements())
    }
}
