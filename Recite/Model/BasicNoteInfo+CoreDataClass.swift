//
//  BasicNoteInfo+CoreDataClass.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//
//

import Foundation
import CoreData


public class BasicNoteInfo: NSManagedObject
{
    class func isNoteExist(name: String, type: String, in context: NSManagedObjectContext) -> Bool
    {
        let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ && type == %@", name, type)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return true
            }
        } catch {
            fatalError("BasicNoteInfo.isNoteExist -- database fetch error \(error)")
        }
        return false
    }
    
    class func findOrCreate(matching noteInfo: MyBasicNoteInfo, in context: NSManagedObjectContext) throws -> BasicNoteInfo {
        let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ && type == %@", noteInfo.name, noteInfo.type)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                matches[0].numberOfCard = Int32(noteInfo.numberOfCard)
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let basicNote = BasicNoteInfo(context: context)
        basicNote.id = Int32(noteInfo.id)
        basicNote.name = noteInfo.name
        basicNote.type = noteInfo.type
        basicNote.createTime = noteInfo.time as NSDate
        basicNote.numberOfCard = Int32(noteInfo.numberOfCard)
        return basicNote
    }
    
    class func find(matching id: Int32, in context: NSManagedObjectContext) -> BasicNoteInfo? {
        let request: NSFetchRequest<BasicNoteInfo> = BasicNoteInfo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                return matches[0]
            }
        } catch {
            print("BasicNoteInfo - find - error: \(error)")
        }
        return nil
    }
}
