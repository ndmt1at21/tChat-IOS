//
//  ChatLogViewController+Emotion.swift
//  MeloApp
//
//  Created by Minh Tri on 12/31/20.
//

import UIKit

extension ChatLogViewController {
    func handleEmotionInputViewWillShow() {
        
        isEmotionInputShow = true
        
        if !emotionInputView.isDescendant(of: self.view) {
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            emotionInputView.frame = CGRect(
                x: 0,
                y: screenHeight - EmotionInputView.kHeightEmotionInputView,
                width: screenWidth,
                height: EmotionInputView.kHeightEmotionInputView
            )
            
            self.view.addSubview(self.emotionInputView)
            emotionInputView.frame.origin.y = screenHeight
        
            self.emotionInputView.frame.origin.y = screenHeight - EmotionInputView.kHeightEmotionInputView
        }

        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom
        
        bottomConstraintChatLogContentView.constant = EmotionInputView.kHeightEmotionInputView - bottomPadding
        
        scrollToBottom(animation: false)
        
        view.layoutIfNeeded()
    }
    
    func handleEmotionInputViewWillHide() {
        
        if !isEmotionInputShow { return }

        isEmotionInputShow = false
     
        if !isKeyboardShow {
            bottomConstraintChatLogContentView.constant = 0
        }
        
        view.layoutIfNeeded()
    }
}

extension ChatLogViewController: EmotionInputViewDelegate {
    func emotionInput(_ emotionInput: EmotionInputView, didSelectedAt sticker: Sticker) {
        
        if sticker.type! == .emoji {
            chatTextView.text += sticker.content!
        } else if sticker.type! == .sticker {
            
        }
    }
}
