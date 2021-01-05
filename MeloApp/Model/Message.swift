//
//  Message.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation
import Firebase

struct Message {
    var uid: StringUID?
    var senderAvatar: String?
    var sendBy: StringUID?
    var sendAt: Any? // Date or FieldValue
    var type: TypeMessage?
    var content: String?
    var thumbnail: String?
    var imageWidth: UInt64?
    var imageHeight: UInt64?
    
    init(uid: StringUID, dataFromServer: [String: Any]) {
        self.uid = uid
        self.sendBy = dataFromServer["sendBy"] as? StringUID
        self.type = TypeMessage(rawValue: dataFromServer["type"] as! Int)
        self.content = dataFromServer["content"] as? String
        self.thumbnail = dataFromServer["thumbnail"] as? String
        self.imageWidth = dataFromServer["imageWidth"] as? UInt64
        self.imageHeight = dataFromServer["imageHeight"] as? UInt64
        
        self.sendAt = (dataFromServer["sendAt"] as? Timestamp)?.dateValue()
    }
    
    init(_ sendBy: StringUID?, _ type: TypeMessage?, _ content: String?, _ thumbnail: String?, _ imageWidth: UInt64?, _ imageHeight: UInt64?) {
        
        self.sendBy = sendBy
        self.sendAt = FieldValue.serverTimestamp()
        self.type = type
        self.content = content
        self.thumbnail = thumbnail
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }
    
    init(_ sendBy: StringUID?, _ type: TypeMessage?, _ content: String?) {
        
        self.sendAt = FieldValue.serverTimestamp()
        self.sendBy = sendBy
        self.type = type
        self.content = content
    }
    
    func dictionaryForSend() -> [String: Any] {
        var dict: [String: Any] = [:]
       
        dict["senderAvatar"] = senderAvatar
        dict["sendBy"] = sendBy
        dict["sendAt"] = FieldValue.serverTimestamp()
        dict["type"] = type?.rawValue
        dict["content"] = content
        dict["thumbnail"] = thumbnail
        dict["imageWidth"] = imageWidth
        dict["imageHeight"] = imageHeight
        
        return dict
    }
}
