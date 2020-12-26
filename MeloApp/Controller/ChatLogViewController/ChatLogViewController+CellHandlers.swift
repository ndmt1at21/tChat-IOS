//
//  ChatLogViewController+cellHandlers.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit

extension ChatLogViewController: BubbleBaseChatDelegate {
    func cellLongPress(_ cell: BubbleBaseChat) {
        print("long tap")
    }
    
    func cellDidTapAvatar(_ cell: BubbleBaseChat) {
        print("djsfh")
    }
    
    func cellDidTapText(_ cell: BubbleBaseChat) {
        print("text tap")
    }
    
    func cellDidTapImage(_ cell: BubbleBaseChat) {
        performSegue(withIdentifier: K.segueID.imageToZoomView, sender: cell)
    }
    
    func cellDidTapVideo(_ cell: BubbleBaseChat) {
        print("video tap")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueID.imageToZoomView {
            let controller = segue.destination as! ImageDetailViewController
            let cell = sender as! BubbleImageChat
            
            controller.originUrlImage = URL(string: cell.messageModel!.content!)
        }
    }
}
