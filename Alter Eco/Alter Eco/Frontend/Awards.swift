import Foundation

public struct Awards: Identifiable, Codable {
    public let id: Int
    public let Name: String
    public let Description: String
    public let BadgeTitle: String
    public var Awarded: Bool
    
    public init(id: Int, name: String, description: String, badgeTitle: String, awarded: Bool = false) {
        self.id = id
        self.Name = name
        self.Description = description
        self.BadgeTitle = badgeTitle
        self.Awarded = awarded
    }
}
