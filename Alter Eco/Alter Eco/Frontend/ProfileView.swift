import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    @EnvironmentObject var chartModel: TransportBarChartModel
    @Environment(\.DBMS) var DBMS

    var body: some View {
        let dailyCarbon = getDailyCarbon()
        return ScrollView {
            VStack() {
                VStack(alignment: .center) {
                    ProfileImage()
                    NameView()
                }
                .frame(height: 0.4*screenMeasurements.trasversal)
                .padding()
                
//                MainBarChart().frame(height: 0.5*screenMeasurements.trasversal).padding(.bottom)
                
                ProgressBarView(latestScore: getCurrentScore()).padding(.bottom)

                ComparisonView(dailyCarbon: dailyCarbon).padding(.bottom)
                
                HighlightView(dailyCarbon: dailyCarbon)
            }.padding(.horizontal)
        }
    }
    
    private func loadStoredImage() -> UIImage? {
        let results = (try? DBMS.executeQuery(entity: "ProfilePic", predicate: nil, args: nil) as? [NSManagedObject]) ?? []
        if results.count > 0 {
            return UIImage(data: results[0].value(forKey: "imageP")! as! Data)
        }
        
        // if not found
        return nil
    }
    
    private func getCurrentScore() -> UserScore {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return (try? appDelegate.DBMS.retrieveLatestScore()) ?? UserScore.getInitialScore()
        }
        return UserScore.getInitialScore()
    }
    
    private func getDailyCarbon() -> Double {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            var now = Date()
            now = now.setToSpecificHour(hour: "00:00:00")?.toGlobalTime() ?? now
            return (try? appDelegate.DBMS.carbonFromPollutingMotions(from: now, interval: DAY_IN_SECONDS)) ?? 0
        }
        return 0
    }
    
}

struct ProfileImage: View {
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @Environment(\.DBMS) var DBMS

    init() {
        _inputImage = State(initialValue: loadStoredImage())
    }
    
    var body: some View {
        GeometryReader { geo in
            Group {
                if self.inputImage != nil {
                    self.resizeImageToFitHeight(image: self.inputImage!, height: geo.size.height)
                        .clipShape(Circle())
                        .shadow(radius: 10)
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
        }.onAppear() {
            let currentImg = self.loadStoredImage()
            if self.inputImage != currentImg {
                self.inputImage = currentImg
            }
        }
    }
    
    private func loadStoredImage() -> UIImage? {
        let results = (try? DBMS.executeQuery(entity: "ProfilePic", predicate: nil, args: nil) as? [NSManagedObject]) ?? []
        if results.count > 0 {
            return UIImage(data: results[0].value(forKey: "imageP")! as! Data)
        }
        
        // if not found
        return nil
    }
    
    private func imageSelectionCompleted(image: UIImage?) {
        if let img = image {
            clearDBAndStoreImage(inputImage: img)
            inputImage = img
        }
    }
    
    private func resizeImageToFitHeight(image: UIImage, height: CGFloat) -> some View {
        let widthToHeight = image.size.width / image.size.height
        let width = widthToHeight * height
        let fit = Image(uiImage: image).resizable().clipped()
        return fit.frame(width: width, height: height)
    }
    
    private func clearDBAndStoreImage(inputImage: UIImage) {
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
        return VStack {
            if changingNickname {
                enterNicknameTextField
            }
            else {
                greetingWithChangeButton
            }
        }.onAppear() {
            if self.retrieveNickname() == "" {
                self.changingNickname = true
            }
        }
    }
    
    private var enterNicknameTextField: some View {
        TextField(" Enter Your Nickname", text: $name) {
            UserDefaults.standard.set(self.name, forKey: "Nickname")
            self.changingNickname = false
        }
            .font(.callout)
            .foregroundColor(Color.secondary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    private var greetingWithChangeButton: some View {
        HStack {
            (Text("Hello, ") + Text("\(retrieveNickname())").italic())
            Button(action: {
                self.changingNickname = true
            }) { Image(systemName: "pencil")}
        }.offset(x: 10)
    }
    
    private func retrieveNickname() -> String {
         return UserDefaults.standard.string(forKey: "Nickname") ?? ""
     }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(ScreenMeasurements())
    }
}
