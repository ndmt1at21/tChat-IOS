//
//  ChatLogViewController+Extensions.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit

// MARK: - ScrollToBottom TableView
extension ChatLogViewController {
    internal func scrollToBottom(animation: Bool) {
        tableMessages.reloadData()
        if messages.count > 0 {
            DispatchQueue.main.async {
                self.tableMessages.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: animation)
            }
        }
    }
}

// MARK: Add Child View Controller
extension ChatLogViewController {
    internal func add(_ childController: UIViewController) {
        // Add child view controoler
        addChild(childController)
        
        // Add child view as subview
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(childController.view)
        
        didMove(toParent: self)
    }
    
    internal func remove(_ childController: UIViewController) {
        // Notify
        childController.willMove(toParent: self)
        
        // Remove child view controller
        childController.removeFromParent()
        
        // remove child view
        childController.view.removeFromSuperview()
    }
}
