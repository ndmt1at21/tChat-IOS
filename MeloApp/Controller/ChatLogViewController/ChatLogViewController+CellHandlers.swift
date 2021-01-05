//
//  ChatLogViewController+cellHandlers.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit
import Hero

extension ChatLogViewController: BubbleBaseChatDelegate {
    func cellDidTapSticker(_ cell: BubbleBaseChat) {
        print("tap sticker")
    }

    func cellLongPress(_ cell: BubbleBaseChat) {
        print("long tap")
    }
    
    func cellDidTapAvatar(_ cell: BubbleBaseChat) {
        print("djsfh")
    }
    
    func cellDidTapText(_ cell: BubbleBaseChat) {
        
    }
    
    func cellDidTapImage(_ cell: BubbleBaseChat) {
        performSegue(withIdentifier: K.segueID.imageToZoomView, sender: cell)
    }
    
    func cellDidTapVideo(_ cell: BubbleBaseChat) {
        let cellVideo = cell as! BubbleVideoChat
        
        videoDetailViewController.player = PlayerManager.shared.getPlayer(by: cellVideo.currentItem)
        videoDetailViewController.imageThumbnail = cellVideo.thumbnail.image
        videoDetailViewController.delegate = self
        videoDetailViewController.cellSender = cellVideo
        
        PlayerManager.shared.pause(with: cellVideo.currentItem!)

        videoDetailViewController.view.frame = self.view.bounds
        self.add(videoDetailViewController)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueID.imageToZoomView {
            prepareForImageSegue(for: segue, sender: sender)
        }
    }
    
    private func prepareForImageSegue(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ImageDetailViewController
        let cell = sender as! BubbleImageChat
        
        controller.thumbnail = cell.thumbnail.image
        controller.originUrlImage = URL(string: cell.messageModel!.content!)
    }
}

extension ChatLogViewController: VideoDetailViewControllerDelegate {
    func willDismiss(_ controller: VideoDetailViewController, playingStatus: Bool) {
        if let cell = controller.cellSender {
            
            cell.layerPlayer = controller.layerPlayer
            cell.layerPlayer?.frame = cell.bounds
            cell.thumbnail.layer.insertSublayer(cell.layerPlayer!, at: 0)
            
            if playingStatus {
                cell.isPlaying = true
                PlayerManager.shared.play(with: cell.currentItem!)
            } else {
                cell.isPlaying = false
            }
            cell.loadingAnimation.stopAnimation()
        }
    }
    
    func finishPlaying(_ controller: VideoDetailViewController) {
        if let cell = controller.cellSender {
            cell.currentItem?.seek(to: .zero, completionHandler: nil)
            print("finisgh playing")
        }
    }
}
