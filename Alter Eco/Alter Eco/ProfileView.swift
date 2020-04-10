
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
                        .frame(height: CGFloat(screenMeasurements.broadcastedHeight)*0.37)
                    ScorePoints()
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    Text("Achievements")
                        .font(.title)
                        .fontWeight(.semibold)
                    AwardView()
                    Spacer(minLength: CGFloat(screenMeasurements.broadcastedHeight)*0.04)
                }
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ExplanationView())
            {
                Image(systemName: "questionmark.circle")
                    .scaleEffect(1.5)
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

    var originalDate = Date()
    var currentMonth = ""

    var timeInterval = 0.0
    
    var awardsList = [
        Awards(
            id: 0,
            name: "Bye-Flyer",
            description: "No airplane travel for 1 entire year",
            badgeTitle: "badge_plane",
            awarded: false),
        Awards(
            id: 1,
            name: "Beating the Average",
            description: "Used less carbon than the London average for one week",
            badgeTitle: "badge_london",
            awarded: false),
        Awards(
            id: 2,
            name: "Walker",
            description: "Walked more than 10 kms in a week",
            badgeTitle: "badge_feet",
            awarded: false),
        Awards(
            id: 3,
            name: "No Wheels",
            description: "No car or bus travel for one week",
            badgeTitle: "badge_wheels",
            awarded: false),
        Awards(
            id: 4,
            name: "Staying Inside for COVID-19",
            description: "Travelled less than 300m in a week",
            badgeTitle: "badge_crown",
            awarded: false),
    ]
       
    init() {
        self.currentMonth = getMonth()
        self.originalDate = getFirstDate()
        ///Uncomment below to show some of the awards
        //self.originalDate = Date(timeIntervalSinceNow: -50000000 * 60)
        self.timeInterval = Date().timeIntervalSince(self.originalDate)

        if(queryPastMonth(motionType:MeasuredActivity.MotionType.plane, month: currentMonth) == 0 && timeInterval > SECONDS_MONTH)
        {awardsList[0].Awarded = true}
        
        if(queryTotalWeek() < LONDON_AVG_CARBON_WEEK && timeInterval > SECONDS_WEEK)
        {awardsList[1].Awarded = true}
        
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.walking, month: currentMonth, carbon: false) > 1000 && timeInterval > SECONDS_MONTH)
        {awardsList[2].Awarded = true}
        
        if(queryPastMonth(motionType: MeasuredActivity.MotionType.car, month: currentMonth) == 0 && timeInterval > SECONDS_MONTH)
        {awardsList[3].Awarded = true}
        
        if(queryPastMonthAll(month: currentMonth, carbon: false) < 300 && timeInterval > SECONDS_MONTH)
        {awardsList[4].Awarded = true}
    }
    
    var body: some View {
        ForEach(awardsList) { award in
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("fill_colour"))
                    .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.9, height: CGFloat(self.screenMeasurements.broadcastedWidth)*0.35)
                HStack{
                    VStack{
                        Text(award.Name).font(.headline)

                        Text(award.Description).font(.caption)
                    }
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.5, alignment: .center)
                        .padding(4)
                                   
                    Image(award.Awarded ? award.BadgeTitle : "badge_empty")
                        .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.22, height: CGFloat(self.screenMeasurements.broadcastedWidth)*0.22, alignment: .center)
                        .scaleEffect(CGFloat(self.screenMeasurements.broadcastedWidth)/1200)
                        .padding(4)
                }
            }
                .frame(width: CGFloat(self.screenMeasurements.broadcastedWidth)*0.85, height: CGFloat(self.screenMeasurements.broadcastedWidth)*0.4)
                .opacity(award.Awarded ? 1.0 : 0.6)
        }
    }
    
   /* func getYear(dateArg: Date = Date()) -> Int {
        let date = dateArg
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let currentYear = components.year
        return currentYear!
    }*/
    
    func getMonth(dateArg: Date = Date()) -> String {
        let date = dateArg
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let monthString = dateFormatter.string(from: date)
        return monthString
    }
    
   /* func getDay(dateArg: Date = Date()) -> Int {
        let date = dateArg
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date)
        let dayOfMonth = components.day
        return dayOfMonth!
    }*/
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
        newPic.imageP = self.inputImage?.jpegData(compressionQuality: CGFloat(1.0))
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
