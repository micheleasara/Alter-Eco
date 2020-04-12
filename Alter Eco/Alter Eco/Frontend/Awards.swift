
import Foundation

struct Awards: Identifiable {
    
    let id: Int
    let Name: String
    let Description: String
    let BadgeTitle: String
    var Awarded: Bool
    
    public init(id: Int, name: String, description: String, badgeTitle: String, awarded: Bool) {
        self.id = id
        self.Name = name
        self.Description = description
        self.BadgeTitle = badgeTitle
        self.Awarded = awarded
       }
}
