import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var screenMeasurements: ScreenMeasurements
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileImage()
                    .frame(height: 0.4*screenMeasurements.trasversal)
                    .padding(.bottom)
                NameView().padding(.bottom)
                
                MainBarChart().frame(height: screenMeasurements.longitudinal / 4).padding(.bottom)
                
                ProgressBarView().padding(.bottom)

                ComparisonView().padding(.bottom)

                HighlightView()
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
                    self.resizeImageToFitHeight(image: UIImage(named: "add_profile_pic")!, height: 0.9*geo.size.height)
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
        HStack {
            Text("Hello, \(nickname)!")
                .foregroundColor(Color.primary)
            Button(action: {
                self.changingNickname = true
            }) { Image(systemName: "pencil")}
        }
    }
    
    func addNickname() {
        self.nickname = name
        UserDefaults.standard.set(self.nickname, forKey: "Nickname")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            ProfileView()
        }.environmentObject(ScreenMeasurements())
    }
}
