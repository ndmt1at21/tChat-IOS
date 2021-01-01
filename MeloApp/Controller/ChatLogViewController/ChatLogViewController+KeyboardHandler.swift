//
//  ChatLogViewController+keyboardHandler.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit

extension ChatLogViewController {
    func setupObserverKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        
        isKeyboardShow = true
        isEmotionInputShow = false
        
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom
        
        let heightKeyboard = keyboardFrame!.height - bottomPadding
        bottomConstraintChatLogContentView.constant = heightKeyboard
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
            
        } completion: { (_) in
            
        }
        self.scrollToBottom(animation: false)
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        
        isKeyboardShow = false
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        if !isEmotionInputShow {
            bottomConstraintChatLogContentView.constant = 0
            UIView.animate(withDuration: keyboardDuration!) {
                self.view.layoutIfNeeded()
            }
        } else {
            print("layout ")
            self.view.layoutIfNeeded()
        }
    }
}

