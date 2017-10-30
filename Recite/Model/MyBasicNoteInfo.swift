//
//  MyBasicNoteInfo.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

struct MyBasicNoteInfo {
    var id: Int
    var time: Date
    var type: String
    var name: String
    var numberOfCard: Int
    
    static func nextNoteID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "noteID")
        userDefaults.set(currentID + 1, forKey: "noteID")
        userDefaults.synchronize()
        return currentID
    }
    
    static func convertToMyBasicNoteInfo(basicNoteInfo: BasicNoteInfo) -> MyBasicNoteInfo {
        return MyBasicNoteInfo(id: Int(basicNoteInfo.id), time: basicNoteInfo.createTime as Date, type: basicNoteInfo.type, name: basicNoteInfo.name, numberOfCard: Int(basicNoteInfo.numberOfCard))
    }
}
