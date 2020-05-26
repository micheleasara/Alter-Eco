import Foundation
import CoreData

@objc(ProfilePic)
public class ProfilePic: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfilePic> {
        return NSFetchRequest<ProfilePic>(entityName: "ProfilePic")
    }

    @NSManaged public var imageP: Data?
}
