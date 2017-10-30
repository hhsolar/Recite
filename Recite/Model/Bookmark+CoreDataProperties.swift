//
//  Bookmark+CoreDataProperties.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


extension Bookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var readPage: Int32
    @NSManaged public var readPageStatus: String?
    @NSManaged public var readType: String
    @NSManaged public var time: NSDate?

}
