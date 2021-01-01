//
//  ChatLogViewController+TableMessage.swift
//  MeloApp
//
//  Created by Minh Tri on 12/28/20.
//

import UIKit

// MARK: - SetupTableView
extension ChatLogViewController {
    func setupTableMessages() {
        tableMessages.delegate = self
        tableMessages.dataSource = self
        tableMessages.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tableMessages.register(UINib(nibName: K.nib.bubbleTextChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleTextChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleImageChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleImageChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleVideoChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleVideoChat)
    }
}

// MARK: - TableViewDelegate
extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let type = messages[indexPath.row].type {
            return type.bubbleHeight(messages[indexPath.row])
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
 
        if let type = messages[indexPath.row].type {
            return type.bubbleHeight(messages[indexPath.row])
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let videoCell = cell as? BubbleVideoChat, let currentItem = videoCell.currentItem {
            PlayerManager.shared.removePlayerItem(currentItem, videoCell)
            videoCell.currentItem = nil
            NotificationCenter.default.removeObserver(self)
            
        }
    }
}


// MARK: - TableViewDataSource
extension ChatLogViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let type: TypeMessage = messages[indexPath.row].type!

        return type.bubbleChatCell(tableView, message: message, self)
    }
}
