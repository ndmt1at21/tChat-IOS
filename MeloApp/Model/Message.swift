//
//  Message.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct Message: Codable {
    var uid: StringUID?
    var senderAvatar: String?
    var sendBy: StringUID?
    var sendAt: UInt64?
    var type: TypeMessage?
    var content: String?
    var thumbnail: String?
    var imageWidth: UInt64?
    var imageHeight: UInt64?
    var idLocalPending: StringUID?
    
    init(uid: StringUID, dictionary: [String: Any]) {
        self.uid = uid
        self.sendBy = dictionary["sendBy"] as? StringUID
        self.sendAt = dictionary["sendAt"] as? UInt64
        self.type = TypeMessage(rawValue: dictionary["type"] as! Int)
        self.content = dictionary["content"] as? String
        self.thumbnail = dictionary["thumbnail"] as? String
        self.imageWidth = dictionary["imageWidth"] as? UInt64
        self.imageHeight = dictionary["imageHeight"] as? UInt64
        self.idLocalPending = dictionary["idLocalPending"] as? StringUID
    }
    
    init(_ sendBy: StringUID?, _ sendAt: UInt64?, _ type: TypeMessage?, _ content: String?, _ thumbnail: String?, _ imageWidth: UInt64?, _ imageHeight: UInt64?, _ idLocalPending: StringUID) {
        
        self.sendBy = sendBy
        self.sendAt = sendAt
        self.type = type
        self.content = content
        self.thumbnail = thumbnail
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.idLocalPending = idLocalPending
    }
    
    init(_ sendBy: StringUID?, _ sendAt: UInt64?, _ type: TypeMessage?, _ content: String?) {
        
        self.sendBy = sendBy
        self.sendAt = sendAt
        self.type = type
        self.content = content
    }
    

}
