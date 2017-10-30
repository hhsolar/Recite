//
//  BasicNoteInfo+CoreDataProperties.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


extension BasicNoteInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BasicNoteInfo> {
        return NSFetchRequest<BasicNoteInfo>(entityName: "BasicNoteInfo")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String
    @NSManaged public var type: String
    @NSManaged public var numberOfCard: Int32
    @NSManaged public var createTime: NSDate

}
