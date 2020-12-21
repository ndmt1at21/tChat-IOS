//
//  CurrentUser.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Foundation

class CurrentUser {
    static var uid: String!
    static var name: String!
    static var email: String!
    static var profileImage: String!
    static var lastLogin: UInt64!
    static var isOnline: Bool!
    static var friends: [StringUID] = []
    static var friendRequests: [StringUID] = []
}
