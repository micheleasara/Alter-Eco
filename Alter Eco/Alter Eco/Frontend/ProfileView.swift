import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject private var screenMeasurements: ScreenMeasurements
    @EnvironmentObject private var chartModel: TransportBarChartViewModel
    @EnvironmentObject private var gameViewModel: GameViewModel
    @Environment(\.DBMS) private var DBMS
    @State private var showingInfo = false
    
    var body: some View {
        let dailyCarbon = getDailyCarbon()
        
        return ScrollView {
            VStack() {
                VStack(alignment: .center) {
                    ProfileImage()
                    NameView()
                }
                .frame(height: 0.4*screenMeasurements.trasversal)
                .padding(.horizontal).padding(.top)
                
                scoreLabelWithInfo.padding(.top)
                
                Button(action: {
                    self.gameViewModel.isGameOn = true
                }) {
                    Text("🌳 Tap to enter your virtual forest 🌳").foregroundColor(Color.init(red: 0, green: 0.5, blue: 0))
                }.padding(.horizontal)
                
                ComparisonView(dailyCarbon: dailyCarbon).padding(.top)
                
                HighlightView(dailyCarbon: dailyCarbon).padding(.top)
            }.padding(.horizontal)
        }
    }
    
    private var scoreLabelWithInfo: some View {
        HStack(alignment: .center) {
            Text("Score: ").font(.headline)
            + Text("\(getCurrentScore(), specifier: "%.0f")")
                .font(.headline)

        
        Button(action: {self.showingInfo = true}) {
            Image(systemName: "info.circle")
        }
            .alert(isPresented: $showingInfo) {
                Alert(title: Text("Your Eco Score"), message: Text("We estimate your modes of transport throughout the day. The more eco-friendly your commute is, the more points you earn!"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadStoredImage() -> UIImage? {
        let results = (try? DBMS.executeQuery(entity: "ProfilePic", predicate: nil, args: nil) as? [NSManagedObject]) ?? []
        if results.count > 0 {
            return UIImage(data: results[0].value(forKey: "imageP") as? Data ?? Data())
        }
        
        // if not found
        return nil
    }
    
    private func getCurrentScore() -> Double {
        return (try? DBMS.retrieveLatestScore()) ?? 0
    }
    
    private func getDailyCarbon() -> Double {
        let dayStart = Date().toLocalTime().setToSpecificHour(hour: "00:00:00")?.toGlobalTime() ?? Date()
        let dayEnd = dayStart.addingTimeInterval(DAY_IN_SECONDS)
        let transport = (try? DBMS.carbonFromPollutingMotions(from: dayStart, interval: DAY_IN_SECONDS)) ?? 0
        let foods = (try? DBMS.carbonFromFoods(predicate: "date >= %@ AND date <= %@", args: [dayStart, dayEnd]))?.value ?? 0
        return transport + foods
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
