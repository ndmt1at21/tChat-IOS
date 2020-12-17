//
//  Message.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

enum TypeMessage {
    case text
    case image
    case video
}

struct Message {
    var id: StringUID
    var sendBy: String
    var sendAt: NSNumber
    var type: TypeMessage
    var content: String
}
