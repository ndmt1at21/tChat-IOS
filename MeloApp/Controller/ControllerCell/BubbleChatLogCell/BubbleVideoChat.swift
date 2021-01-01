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
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var layerPlayer: AVPlayerLayer?
    var currentItem: AVPlayerItem?
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playButton.isHidden = true
            } else {
                DispatchQueue.main.async {
                    self.playButton.isHidden = false
                }
            }
        }
    }
    
    let loadingAnimation: LoadingIndicator = {
        let loading = LoadingIndicator(frame: .zero)
        loading.isTurnBlurEffect = false
        loading.colorIndicator = .white
        return loading
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.masksToBounds = true
        
        thumbnail.contentMode = .scaleAspectFill
        progressBar.progress = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleVideoPressed))
        bubbleView.addGestureRecognizer(tap)
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
        
        self.setNeedsLayout()
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
        setupVideoPlayer()
        delegate?.cellDidTapVideo(self)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        setupVideoPlayer()
    }
    
    func setupVideoPlayer() {
        if let messageContent = messageModel?.content, let url = URL(string: messageContent) {
            
            if currentItem == nil {
                currentItem = AVPlayerItem(url: url)
                layerPlayer = PlayerManager.shared.addPlayerItem(item: currentItem!, observer: self)
                layerPlayer?.frame = self.thumbnail.bounds
                layerPlayer?.videoGravity = .resizeAspectFill
                thumbnail.layer.addSublayer(layerPlayer!)
                
                NotificationCenter.default.addObserver(self, selector: #selector(handleAutoPauseVideo), name: NSNotification.Name(rawValue: "PausePlayingVideo"), object: currentItem)
            }
            
            loadingAnimation.frame = thumbnail.bounds
            thumbnail.addSubview(loadingAnimation)
            loadingAnimation.startAnimation()

            // just hidden play button, but actually player loading
            playButton.isHidden = true
            PlayerManager.shared.play(with: currentItem!)
            PlayerManager.shared.delegate = self
        }
    }
    
    @objc func handleAutoPauseVideo(_ noti: Notification) {
        isPlaying = false
        loadingAnimation.stopAnimation()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // player ready to play
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                isPlaying = true
                loadingAnimation.stopAnimation()
            case .failed:
                isPlaying = false
            default:
                isPlaying = false
            }
        } else if keyPath == "loadedTimeRanges" {
            isPlaying = true
            loadingAnimation.stopAnimation()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        thumbnail.kf.cancelDownloadTask()
        thumbnail.image = nil
        
        currentItem = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PausePlayingVideo"), object: currentItem)
        layerPlayer?.removeFromSuperlayer()
        isPlaying = false
        loadingAnimation.stopAnimation()
    }
}

extension BubbleVideoChat: PlayerManagerDelegate {
    func progressUpdated(_ playerManager: PlayerManager, at currentTime: Float64, per duration: Float64) {
    
    }
    
    func didFinishPlaying(_ playerManager: PlayerManager) {
        isPlaying = false
        print("finish?")
        currentItem?.seek(to: .zero, completionHandler: nil)
        PlayerManager.shared.pause(with: currentItem!)
    }
}
