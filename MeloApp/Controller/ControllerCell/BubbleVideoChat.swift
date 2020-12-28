//
//  BubbleVideoChat.swift
//  MeloApp
//
//  Created by Minh Tri on 12/21/20.
//

import UIKit
import AVFoundation
import AVKit

class BubbleVideoChat: BubbleBaseChat {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.masksToBounds = true
        
        thumbnail.contentMode = .scaleAspectFill
        progressBar.progress = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleVideoPressed))
        bubbleView.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnail.image = nil
        thumbnail.kf.cancelDownloadTask()
        
        playButton.isHidden = false
        player?.pause()
        playerLayer?.removeFromSuperlayer()
    }

    override func setupViewCellFromMe() {
        super.setupViewCellFromMe()
    }
    
    override func setupViewCellFromFriend() {
        super.setupViewCellFromFriend()
    }
    
    override func setupContentCell() {
        super.setupContentCell()
        
        if messageModel!.content!.starts(with: "file://") {
            thumbnail.image = thumbnailImageForFileUrl(URL(string: messageModel!.content!)!)
            return
        }
        
        var url: String {
            guard let _ = messageModel?.thumbnail else {
                return messageModel!.content!
            }
            return messageModel!.thumbnail!
        }
        
        // load image from url
        let imgLoad = ImageLoading()
        imgLoad.loadingImageAndCaching(
            target: thumbnail,
            with: url,
            placeholder: nil) { (downloaded, totalSize) in
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = false
                self.progressBar.progress = Float(downloaded) / Float(totalSize)
            }
        } completion: { (error) in
            if error != nil {
                print("Error: ", error!)
                return
            }
            
            self.setNeedsLayout()
            self.progressBar.isHidden = true
        }
    }
    
    class func cellHeight(_ message: Message) -> CGFloat {
        let realWidth = message.imageWidth!
        let realHeight = message.imageHeight!
        
        let resizeWidth = 0.7 * UIScreen.main.bounds.width
        let resizeHeight = CGFloat(realHeight) * resizeWidth / CGFloat(realWidth)
        
        return resizeHeight
    }
    
    @objc func handleFinishVideo() {
        playButton.isHidden = false
    }
    
    @objc func bubbleVideoPressed(sender: UITapGestureRecognizer) {
        delegate?.cellDidTapVideo(self)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if let messageContent = messageModel?.content, let url = URL(string: messageContent) {
            
            DispatchQueue.main.async {
                self.player = AVPlayer(url: url)
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleFinishVideo), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer!.frame = self.thumbnail.bounds
                self.playerLayer!.videoGravity = .resizeAspectFill
                self.thumbnail.layer.addSublayer(self.playerLayer!)
                self.playButton.isHidden = true
                
                self.player?.play()
            }
        }
    }
}

fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
    let asset = AVAsset(url: fileUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
    
        let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
        return UIImage(cgImage: thumbnailCGImage)
        
    } catch let err {
        print(err)
    }
    
    return nil
}
