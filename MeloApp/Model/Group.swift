//
//  Group.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct RecentMessage: Codable {
    var message: Message
    var readBy: [StringUID: Bool]?
}

struct Group: Codable {
    var uid: StringUID?
    var createdAt: UInt64?
    var createdBy: StringUID? // uid user
    var members: [StringUID: Bool]? // list uid
    var recentMessage: RecentMessage?
    var displayName: String?
}


