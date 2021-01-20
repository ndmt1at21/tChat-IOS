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
        tableMessages.backgroundColor = .white
        tableMessages.delegate = self
        tableMessages.dataSource = self
        tableMessages.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableMessages.contentInsetAdjustmentBehavior = .never
        
        tableMessages.register(UINib(nibName: K.nib.bubbleTextChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleTextChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleImageChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleImageChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleVideoChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleVideoChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleStickerChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleStickerChat)
    }
}

// MARK: - TableViewDelegate
extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableMessages.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let message = messages[indexPath.section][indexPath.row]
        
        if let type = message.type {
            return type.bubbleHeight(message)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
 
        let message = messages[indexPath.section][indexPath.row]
        
        if let type = message.type {
            return type.bubbleHeight(message)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .systemGray3
        label.text = formatDate(messages[section].first!.sendAt as! Date)
        
        let view = UIView()
        view.frame = .zero
        view.frame.size.height = .leastNormalMagnitude
        view.addSubview(label)
  
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}


// MARK: - TableViewDataSource
extension ChatLogViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        
        let type: TypeMessage = message.type!
        
        let cell = type.bubbleChatCell(tableView, message: message, self)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
}

extension ChatLogViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            if isEndLoadingMore && !isEndMessages {
                pullToLoadMore()
            }
        }
    }

    private func pullToLoadMore() {
        self.isLoadingMore = true
        self.isEndLoadingMore = false
        
        // for get message from .. to.. in firebase
        var uidMessageFlag: StringUID?
        
        if messages.count > 0 {
            uidMessageFlag = messages[0][0].uid!
        }
       
        // start animation loading
        tableMessages.tableHeaderView = loadingIndicator
        loadingIndicator.frame.size.height = 60
        loadingIndicator.startAnimation()
        
        DatabaseController.getMessages(
            from: uidMessageFlag,
            in: group.uid!, limit: 10) { (messagesFetched) in
            
            self.loadingIndicator.stopAnimation()
            self.tableMessages.tableHeaderView = nil
            
            self.isLoadingMore = false
            self.isEndLoadingMore = true
            
            if messagesFetched.count < 10 {
                self.isEndMessages = true
            }
            
            // nothing fetched
            if messagesFetched.count == 0 {
                return
            }
            
            let oldSectionSize = self.messages.count
            self.messages.addSectionFirst(messagesFetched)
            let newSectionSize = self.messages.count
    
            self.updateTableMessageWithNewSections(newSectionSize - oldSectionSize)
        }
    }
    
    private func updateTableMessageWithNewSections(_ nSection: Int) {
        let oldOffsetY = self.tableMessages.contentOffset.y
        let oldHeightOffset = self.tableMessages.contentSize.height
        
        // prevent scroll when insert section
        UIView.setAnimationsEnabled(false)
        
        self.tableMessages.beginUpdates()
        self.tableMessages.deleteSections(IndexSet(integer: 0), with: .fade)
        self.tableMessages.insertSections(IndexSet(integersIn: 0...nSection), with: .fade)
        self.tableMessages.endUpdates()
        
        let newHeightOffset = self.tableMessages.contentSize.height
        self.tableMessages.contentOffset.y = oldOffsetY + (newHeightOffset - oldHeightOffset)
        
        UIView.setAnimationsEnabled(true)
    }
}
