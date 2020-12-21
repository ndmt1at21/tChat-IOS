//
//  User.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct User: Codable {
    var uid: StringUID
    var name: String
    var email: String
    var profileImage: String?
    var friends: [StringUID]?
    var friendRequests: [StringUID]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case email
        case profileImage
        case friends
        case friendRequests
    }
}
