import Foundation
import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject private var screenMeasurements: ScreenMeasurements
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var showingInfo = false
    
    var body: some View {
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
                
                ComparisonView(dailyCarbon: profileViewModel.dailyCarbon).padding(.top)
                
                HighlightView(dailyCarbon: profileViewModel.dailyCarbon).padding(.top)
            }.padding(.horizontal)
        }
    }
    
    private var scoreLabelWithInfo: some View {
        HStack(alignment: .center) {
            Text(String(format: "Score: %.0f", profileViewModel.score)).font(.headline)
        
            Button(action: {self.showingInfo = true}) {
                Image(systemName: "info.circle")
            }
            .alert(isPresented: $showingInfo) {
                Alert(title: Text("Your Eco Score"), message: Text("We estimate your modes of transport throughout the day. The more eco-friendly your commute is, the more points you earn!"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ProfileImage: View {
    @State private var showingImagePicker = false
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        GeometryReader { geo in
            self.resizeImageToFitHeight(image: viewModel.profilePicture, height: geo.size.height)
                .clipShape(Circle())
                .shadow(radius: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .sheet(isPresented: self.$showingImagePicker) {
                    ImagePicker(onCompletionCallback: self.imageSelectionCompleted(image:))
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
        }
    }
    
    private func imageSelectionCompleted(image: UIImage?) {
        if let img = image {
            viewModel.save(image: img)
        }
    }
    
    private func resizeImageToFitHeight(image: UIImage, height: CGFloat) -> some View {
        let widthToHeight = image.size.width / image.size.height
        let width = widthToHeight * height
        let fit = Image(uiImage: image).resizable().clipped()
        return fit.frame(width: width, height: height)
    }
}

struct NameView: View {
    @State private var changingNickname = false
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        return VStack {
            if changingNickname || viewModel.nickname.isEmpty {
                enterNicknameTextField
            }
            else {
                greetingWithChangeButton
            }
        }
    }
    
    private var enterNicknameTextField: some View {
        TextField(" Enter Your Nickname", text: $viewModel.nickname, onCommit:  {
            self.changingNickname = false
            viewModel.save(nickname: viewModel.nickname)
        })
            .font(.callout)
            .foregroundColor(Color.secondary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    private var greetingWithChangeButton: some View {
        HStack {
            (Text("Hello, ") + Text("\(viewModel.nickname)").italic())
            Button(action: {
                self.changingNickname = true
            }) { Image(systemName: "pencil")}
        }.offset(x: 10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(ScreenMeasurements()).environmentObject(ProfileViewModel(DBMS: CoreDataManager()))
    }
}
