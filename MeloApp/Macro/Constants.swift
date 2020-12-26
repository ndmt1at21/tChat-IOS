//
//  Constants.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import Foundation
import UIKit

struct K {
    struct cellID {
        static let conversationPrivate = "ConversationPrivateCell"
        static let conversationGroup = "ConversationGroupCell"
        static let contactCell = "ContactCell"
        static let onlineFriend = "OnlineFriendCell"
        static let bubbleTextChat = "BubbleTextChat"
        static let bubbleImageChat = "BubbleImageChat"
        static let bubbleVideoChat = "BubbleVideoChat"
    }
    
    struct nib {
        static let bubbleImageChat = "BubbleImageChat"
        static let bubbleTextChat = "BubbleTextChat"
        static let bubbleVideoChat = "BubbleVideoChat"
    }
    
    struct segueID {
        static let loginToConversation = "LoginToConversations"
        static let registerToConversation = "RegisterToConversation"
        static let newMessageToChatLog = "NewMessageToChatLog"
        static let conversationToChatLog = "ConversationToChatLog"
        static let imageToZoomView = "ImageToImageZoomView"
    }
    
    static let primaryColor = UIColor(named: "primaryBlue") ?? UIColor.systemBlue
    static let secondaryColor = UIColor(named: "lightBlue") ?? UIColor.blue
    
    static let defaultAvatar = "https://firebasestorage.googleapis.com/v0/b/tchat-69560.appspot.com/o/default%2Fdefault-avatar.jpg?alt=media&token=4194f32f-6656-4683-9a63-ced6995c3e46"
}
