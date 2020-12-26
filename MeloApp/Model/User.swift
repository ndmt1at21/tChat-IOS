//
//  User.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct User: Codable {
    var uid: StringUID?
    var name: String?
    var email: String?
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
    
    init(uid: StringUID, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImage = dictionary["profileImage"] as? String
        self.friends = dictionary["friends"] as? [StringUID]
        self.friendRequests = dictionary["friendRequests"] as? [StringUID]
    }
}
