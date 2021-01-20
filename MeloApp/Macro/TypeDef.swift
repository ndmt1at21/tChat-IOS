//
//  TypeDef.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import Foundation

typealias StringUID = String
typealias StringHex = String

enum MessageDestination {
    case me
    case friend
}

enum StatusPlaying {
    case loading
    case playing
    case pause
}
