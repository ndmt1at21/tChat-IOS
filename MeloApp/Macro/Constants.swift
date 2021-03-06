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
        static let bubbleStickerChat = "BubbleStickerChat"
        static let friendRequestCell = "FriendRequestCell"
        static let headerUserSettingCell = "HeaderUserSettingCell"
        static let userSettingCell = "UserSettingCell"
        static let customizeChatCell = "CustomizeChatCell"
        static let headerContactCell = "HeaderContactCell"
    }
    
    struct nib {
        static let bubbleImageChat = "BubbleImageChat"
        static let bubbleTextChat = "BubbleTextChat"
        static let bubbleVideoChat = "BubbleVideoChat"
        static let bubbleStickerChat = "BubbleStickerChat"
    }
    
    struct segueID {
        static let loginToConversation = "LoginToConversations"
        static let registerToConversation = "RegisterToConversation"
        static let newMessageToChatLog = "NewMessageToChatLog"
        static let conversationToChatLog = "ConversationToChatLog"
        static let imageToZoomView = "ImageToImageZoomView"
        static let videoToDetailView = "VideoToDetailView"
        static let coversationToNewMessage = "ConversationToNewMessage"
    }
    
    struct sbID {
        static let imageDetailViewController = "ImageDetailViewController"
        static let videoDetailViewController = "VideoDetailViewController"
        static let coversationsViewController = "CoversationsViewController"
        static let chatLogViewController = "ChatLogViewController"
        static let newMessageViewController = "NewMessageViewController"
        static let addFriendViewController = "AddFriendViewController"
        static let friendRequestViewController = "FriendRequestViewController"
        static let userSettingViewController = "UserSettingViewController"
        static let rootNavigationController = "RootNavigationController"
        static let groupSettingViewController = "GroupSettingViewController"
    }
    
    static let primaryColor = UIColor(named: "primaryBlue") ?? UIColor.systemBlue
    static let secondaryColor = UIColor(named: "lightBlue") ?? UIColor.blue
    
    static let defaultAvatar = "https://firebasestorage.googleapis.com/v0/b/tchat-69560.appspot.com/o/default%2Fdefault-avatar.jpg?alt=media&token=4194f32f-6656-4683-9a63-ced6995c3e46"
    
    static let distanceTimeGroupMessage: Double = 10 * 60 // 10 minutes
}
