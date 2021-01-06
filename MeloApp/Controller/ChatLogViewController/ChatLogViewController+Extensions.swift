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
        if messages.messages.count > 0 {
            DispatchQueue.main.async {
                let lastIndex = self.messages.messages.count - 1
                self.tableMessages.scrollToRow(
                    at: IndexPath(
                        row: self.messages.messages[lastIndex].count - 1,
                        section: lastIndex
                    ),
                    at: .bottom,
                    animated: animation
                )
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

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    
    let distance = (Date().timeIntervalSince1970 - date.timeIntervalSince1970) / (60 * 60 * 24)
    
    switch distance {
    case 0..<1:
        formatter.dateFormat = "HH:mm"
    case 1..<2:
        formatter.dateFormat = "'Hôm qua' HH:mm"
    case 2..<7:
        formatter.dateFormat = "EE HH:mm"
    case 7...365:
        formatter.dateFormat = "dd MMM HH:mm"
    default:
        formatter.dateFormat = "dd MMM, yyyy"
    }
   
    formatter.locale = Locale(identifier: "vi_VN")

    return formatter.string(from: date)
}
