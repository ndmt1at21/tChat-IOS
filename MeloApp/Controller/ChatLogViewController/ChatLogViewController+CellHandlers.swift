//
//  ChatLogViewController+cellHandlers.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit
import Hero

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
        performSegue(withIdentifier: K.segueID.videoToDetailView, sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueID.imageToZoomView {
            let controller = segue.destination as! ImageDetailViewController
            let cell = sender as! BubbleImageChat
            
            controller.thumbnail = cell.thumbnail.image
            controller.originUrlImage = URL(string: cell.messageModel!.content!)
            
        } else if segue.identifier == K.segueID.videoToDetailView {
            let controller = segue.destination as! VideoDetailViewController
            let cell = sender as! BubbleVideoChat
            
            controller.imageThumbnail = cell.thumbnail.image
            controller.urlVideo = URL(string: cell.messageModel!.content!)
            
            cell.thumbnail.hero.id = "cellVideo"
            self.hero.modalAnimationType = .fade
            navigationController?.hero.isEnabled = true
            navigationController?.hero.navigationAnimationType = .fade
        }
    }
}
