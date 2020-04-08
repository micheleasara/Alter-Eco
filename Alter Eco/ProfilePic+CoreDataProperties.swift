//
//  ProfilePic+CoreDataProperties.swift
//  Alter Eco
//
//  Created by Hannah Kay on 08/04/2020.
//  Copyright © 2020 Imperial College London. All rights reserved.
//
//

import Foundation
import CoreData


extension ProfilePic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfilePic> {
        return NSFetchRequest<ProfilePic>(entityName: "ProfilePic")
    }

    @NSManaged public var imageP: Data?

}
