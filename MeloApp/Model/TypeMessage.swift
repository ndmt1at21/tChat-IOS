//
//  TypeMessage.swift
//  MeloApp
//
//  Created by Minh Tri on 12/24/20.
//

import UIKit

enum TypeMessage: Int, Codable {
    case text
    case image
    case video
}

extension TypeMessage {
    func bubbleChatCell(_ tableView: UITableView, message: Message, _ viewController: ChatLogViewController) -> UITableViewCell {
        
        switch self {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID.bubbleTextChat) as! BubbleTextChat
            cell.messageModel = message
            cell.delegate = viewController
            return cell
            
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID.bubbleImageChat) as! BubbleImageChat
            cell.messageModel = message
            cell.delegate = viewController
            return cell
            
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID.bubbleVideoChat) as! BubbleVideoChat
            cell.messageModel = message
            cell.delegate = viewController
            return cell
        }
    }
    
    func bubbleHeight(_ message: Message) -> CGFloat {
        switch self {
        case .text:
            return BubbleTextChat.cellHeight(message)
            
        case .image:
            return BubbleImageChat.cellHeight(message)
            
        case .video:
            return BubbleVideoChat.cellHeight(message)
        }
    }
}
