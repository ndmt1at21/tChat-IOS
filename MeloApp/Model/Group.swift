//
//  Group.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation
import Firebase

struct RecentMessage {
    var message: Message
    var readBy: [StringUID: Bool]?
    
    func dictionaryForSend() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["message"] = message
        dict["readBy"] = readBy
        
        return dict
    }
}

struct Group {
    var uid: StringUID?
    var createdAt: Any?
    var createdBy: StringUID? // uid user
    var members: [StringUID: Bool]? // list uid
    var recentMessage: RecentMessage?
    var displayName: String?
    var groupImage: String? // url to group's image avatar
    var themeColors: [StringHex]? // list colors in hex
    var backgroundImage: String? // url image
    
    init() {}
    
    init(uid: StringUID?, dataFromServer: [String: Any]) {
        self.uid = uid
        self.createdBy = dataFromServer["createdBy"] as? StringUID
        self.members = dataFromServer["members"] as? [StringUID: Bool]
        self.recentMessage = dataFromServer["recentMessage"] as? RecentMessage
        self.displayName = dataFromServer["displayName"] as? String
        self.groupImage = dataFromServer["groupImage"] as? String
        self.themeColors = dataFromServer["themColor"] as? [StringHex]
        self.backgroundImage = dataFromServer["backgroundImage"] as? String
    
        self.createdAt = (dataFromServer["createdAt"] as? Timestamp)?.dateValue()
    }
    
    init(createdBy: StringUID?, members: [StringUID: Bool]?, recentMessage: RecentMessage?, displayName: String?) {
        self.createdAt = FieldValue.serverTimestamp()
        self.createdBy = createdBy
        self.members = members
        self.recentMessage = recentMessage
        self.displayName = displayName
    }
    
    func dictionaryForSend() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        dict["uid"] = nil
        dict["createdAt"] = FieldValue.serverTimestamp()
        dict["createdBy"] = createdBy
        dict["members"] = members
        dict["recentMessage"] = recentMessage
        dict["displayName"] = displayName
        dict["groupImage"] = groupImage
        dict["themeColors"] = themeColors
        dict["backgroundImage"] = backgroundImage
        
        return dict
    }
}


