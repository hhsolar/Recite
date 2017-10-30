//
//  Bookmark+CoreDataClass.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


public class Bookmark: NSManagedObject
{
    class func findOrCreate(matching bookmark: MyBookmark, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", bookmark.name)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                matches[0].id = Int32(bookmark.id)
                matches[0].time = bookmark.time as NSDate
                matches[0].readType = bookmark.readType
                matches[0].readPage = Int32(bookmark.readPage)
                matches[0].readPageStatus = bookmark.readPageStatus
            } else {
                let newMark = Bookmark(context: context)
                newMark.name = bookmark.name
                newMark.id = Int32(bookmark.id)
                newMark.time = bookmark.time as NSDate
                newMark.readType = bookmark.readType
                newMark.readPage = Int32(bookmark.readPage)
                newMark.readPageStatus = bookmark.readPageStatus
            }
        } catch {
            print("Bookmark -- findOrCreate -- error: \(error)")
        }
        
        try? context.save()
    }
    
    class func find(matching name: String, in context: NSManagedObjectContext) throws -> Bool {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return true
            }
        } catch {
            throw error
        }
        return false
    }
    
    class func remove(matching id: Int32, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                for i in matches {
                    context.delete(i)
                }
            }
        } catch {
            print("Bookmark -- remove -- error: \(error)")
        }
    }
}
