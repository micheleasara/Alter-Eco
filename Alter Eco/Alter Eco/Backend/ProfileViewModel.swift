import Foundation
import SwiftUI

public class ProfileViewModel: ObservableObject {
    /// The user's profile picture. If no picture is found, it is set to a default image.
    @Published public var profilePicture: UIImage!
    /// The user's nickname. If no nickname is found, it is set to an empty string.
    @Published public var nickname: String!
    /// The user's current score.
    @Published public var score: Double!
    /// The user's carbon footprint from the start of the current day.
    @Published public var dailyCarbon: Double!
    
    private let DBMS: DBManager
    
    public init(DBMS: DBManager) {
        self.DBMS = DBMS
        profilePicture = loadImage()
        nickname = loadNickname()
        refreshScore()
        refreshDailyCarbon()
    }
    
    /// Saves the given image for later use and updates the current picture.
    public func save(image: UIImage) {
        try? DBMS.deleteAll(entity: "ProfilePic")
        if let newPic = image.jpegData(compressionQuality: CGFloat(1.0)) {
            try? DBMS.setValuesForKeys(entity: "ProfilePic", keyedValues: ["imageP":newPic])
        }
        profilePicture = image
    }
    
    /// Saves the given nickname for later use and updates the current nickname.
    public func save(nickname: String) {
        UserDefaults.standard.set(nickname, forKey: "Nickname")
        self.nickname = nickname
    }
    
    /// Updates the score.
    public func refreshScore(){
        score = (try? DBMS.retrieveLatestScore()) ?? 0
    }
    
    /// Updates the amount of carbon since the beginning of the current day.
    public func refreshDailyCarbon() {
        let dayStart = Date().toLocalTime().setToSpecificHour(hour: "00:00:00")?.toGlobalTime() ?? Date()

        dailyCarbon = (try? DBMS.carbonWithinInterval(from: dayStart, addingInterval: DAY_IN_SECONDS))?.value ?? 0
    }
    
    private func loadImage() -> UIImage {
        let standard = UIImage(named: "user_default_picture") ?? UIImage(ciImage: CIImage.empty())
        
        if let image = try? DBMS.getProfilePicture() {
            return image
        }
        
        // if not found
        return standard
    }
    
    private func loadNickname() -> String {
         return UserDefaults.standard.string(forKey: "Nickname") ?? ""
     }
}
