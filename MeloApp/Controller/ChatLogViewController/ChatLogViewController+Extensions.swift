//
//  ChatLogViewController+Extensions.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit

extension ChatLogViewController {
    internal func scrollToBottom() {
        if messages.count > 0 {
            tableMessages.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
}
