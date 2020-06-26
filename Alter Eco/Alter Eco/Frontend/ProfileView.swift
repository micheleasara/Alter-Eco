import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @EnvironmentObject var chartModel: TransportBarChartModel
    private(set) var DBMS: DBManager
    
    var body: some View {
        let dailyCarbon = getDailyCarbon()
        return ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center) {
                    ProfileImage(inputImage: loadStoredImage(), DBMS: DBMS)
                    NameView()
                }
                .frame(height: 0.4*screenMeasurements.trasversal)
                .padding(.bottom)
                
                MainBarChart().frame(height: 0.5*screenMeasurements.trasversal).padding(.bottom)
                
                ProgressBarView(latestScore: getCurrentScore(), DBMS: DBMS).padding(.bottom)

                ComparisonView(dailyCarbon: dailyCarbon).padding(.bottom)
                
                HighlightView(dailyCarbon: dailyCarbon)
            }.padding(.horizontal)
        }
    }
    
    func loadStoredImage() -> UIImage? {
        let results = (try? DBMS.executeQuery(entity: "ProfilePic", predicate: nil, args: nil) as? [NSManagedObject]) ?? []
        if results.count > 0 {
            return UIImage(data: results[0].value(forKey: "imageP")! as! Data)
        }
        
        // if not found
        return nil
    }
    
    func getCurrentScore() -> UserScore {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return (try? appDelegate.DBMS.retrieveLatestScore()) ?? UserScore.getInitialScore()
        }
        return UserScore.getInitialScore()
    }
    
    func getDailyCarbon() -> Double {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            var now = Date().toLocalTime()
            now = now.setToSpecificHour(hour: "00:00:00") ?? now
            return (try? appDelegate.DBMS.carbonFromPollutingMotions(from: now, interval: DAY_IN_SECONDS)) ?? 0
        }
        return 0
    }
    
}

struct ProfileImage: View {
    @State private var showingImagePicker = false
    @State private(set) var inputImage: UIImage?
    private(set) var DBMS: DBManager
    
    var body: some View {
        GeometryReader { geo in
            Group {
                if self.inputImage != nil {
                    self.resizeImageToFitHeight(image: self.inputImage!, height: geo.size.height).clipShape(Circle())
                } else {
                    self.resizeImageToFitHeight(image: UIImage(named: "add_profile_pic")!, height: 0.9*geo.size.height)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
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

struct NameView: View {
    @State private var name: String = ""
    @State private var changingNickname = false
    
    var body: some View {
        VStack {
            if(retrieveNickname() == "" || changingNickname) {
                enterNicknameTextField
            }
            else {
                greetingWithChangeButton
            }
        }
    }
    
    var enterNicknameTextField: some View {
        TextField(" Enter Your Nickname", text: $name) {
            UserDefaults.standard.set(self.name, forKey: "Nickname")
            self.changingNickname = false
        }
            .font(.callout)
            .foregroundColor(Color.secondary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    var greetingWithChangeButton: some View {
        HStack {
            (Text("Hello, ") + Text("\(retrieveNickname())").italic())
            Button(action: {
                self.changingNickname = true
            }) { Image(systemName: "pencil")}
        }.offset(x: 10)
    }
    
    func retrieveNickname() -> String {
         return UserDefaults.standard.string(forKey: "Nickname") ?? ""
     }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            ProfileView(DBMS: CoreDataManager())
        }.environmentObject(ScreenMeasurements())
    }
}
