//
//  User.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

struct User {
    var name: String?
    var email: String?
    var profileImage: String?
    var lastLogin: NSNumber?
    var isOnline: Bool?
    
    init(name: String?, email: String?, profileImgUrl: String?, lastLogin: NSNumber?, isOnline: Bool?) {
        self.name = name
        self.email = email
        self.profileImage = profileImgUrl
        self.lastLogin = lastLogin
        self.isOnline = isOnline
    }
}
