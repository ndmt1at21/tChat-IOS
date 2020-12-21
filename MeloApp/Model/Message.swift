//
//  Message.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

enum TypeMessage: Int, Codable {
    case text
    case image
    case video
}

struct Message: Codable {
    var uid: StringUID
    var sendBy: StringUID
    var sendAt: UInt64?
    var type: TypeMessage?
    var content: String?
}
