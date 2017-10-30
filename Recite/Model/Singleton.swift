//
//  Singleton.swift
//  Recite
//
//  Created by apple on 29/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

class UserInfo {
    private static var instance: UserInfo = UserInfo()
    static var shared: UserInfo {
        return instance
    }
    var uid: String = ""
    var userName: String = ""
    var userMotto: String = ""
    
    var portraitPhotoURL: URL {
        let filename = "uid.jpg"
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var portraitPhotoImage: UIImage? {
        return UIImage(contentsOfFile: portraitPhotoURL.path)
    }
}

class SoundSwitch {
    private static var instance: SoundSwitch = SoundSwitch()
    static var shared: SoundSwitch {
        return instance
    }
    var isSoundOn: Bool = true
}
