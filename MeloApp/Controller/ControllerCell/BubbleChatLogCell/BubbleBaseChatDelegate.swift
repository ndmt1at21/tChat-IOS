//
//  BubbleBaseChatDelegate.swift
//  MeloApp
//
//  Created by Minh Tri on 12/24/20.
//

import Foundation

@objc protocol BubbleBaseChatDelegate : class {
    
    @objc func cellDidTapAvatar(_ cell: BubbleBaseChat)
    
    func cellDidTapText(_ cell: BubbleBaseChat)
    
    func cellDidTapImage(_ cell: BubbleBaseChat)
    
    func cellDidTapSticker(_ cell: BubbleBaseChat)
    
    func cellDidTapVideo(_ cell: BubbleBaseChat)
    
    func cellLongPress(_ cell: BubbleBaseChat)
}
