//
//  Group.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct RecentMessage {
    var message: Message
    var readBy: [StringUID]
}

struct Group {
    var id: StringUID?
    var createdAt: NSNumber?
    var createdBy: StringUID? // uid user
    var memberIDs: [StringUID] // list uid
    var recentMessage: RecentMessage?
    var displayName: String?
}


