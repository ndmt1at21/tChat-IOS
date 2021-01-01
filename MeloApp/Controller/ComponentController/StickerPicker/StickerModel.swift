//
//  StickerModel.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import Foundation

enum StickerType {
    case sticker
    case emoji
}

struct Sticker {
    var content: String?
    var type: StickerType?
}
