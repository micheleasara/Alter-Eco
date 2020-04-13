import Foundation
import CoreData


extension ProfilePic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfilePic> {
        return NSFetchRequest<ProfilePic>(entityName: "ProfilePic")
    }

    @NSManaged public var imageP: Data?

}
