//
//  CardContent.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

struct CardContent {
    var title: NSAttributedString
    var body: NSAttributedString
    
    static func getCardContent(with noteName: String, at index: Int, in noteType: String) -> CardContent
    {
        let titleAtt = NSAttributedString.getTextFromFile(with: noteName, at: index, in: noteType, contentType: "title")
        let bodyAtt = NSAttributedString.getTextFromFile(with: noteName, at: index, in: noteType, contentType: "body")
        return CardContent(title: titleAtt, body: bodyAtt)
    }
    
    static func removeCardContent(with noteName: String, at index: Int, in noteType: String) {
        CardContent.removeTextFile(with: noteName, at: index, in: noteType, contentType: "title")
        CardContent.removeTextFile(with: noteName, at: index, in: noteType, contentType: "body")
    }
    
    static func removeTextFile(with noteName: String, at index: Int, in noteType: String, contentType: String) {
        let fileName = "\(noteType)-\(noteName)-\(index)-\(contentType)"
        let url = applicationDocumentsDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing file: \(error)")
        }
    }
    
    func saveCardContentToFile(cardIndex: Int, noteName: String, noteType: String) {
        self.title.saveTextToFile(with: noteName, at: cardIndex, in: noteType, contentType: "title")
        self.body.saveTextToFile(with: noteName, at: cardIndex, in: noteType, contentType: "body")
    }
}
