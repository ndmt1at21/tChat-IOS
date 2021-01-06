//
//  BubbleStickerChat.swift
//  MeloApp
//
//  Created by Minh Tri on 1/3/21.
//

import UIKit

class BubbleStickerChat: BubbleBaseChat {

    @IBOutlet weak var stickerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressBar.isHidden = true
    
        stickerImageView.contentMode = .scaleAspectFill
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleImagePressed))
        stickerImageView.addGestureRecognizer(tap)
    }
    
    override func setupViewCellFromMe() {
        super.setupViewCellFromMe()
    }
    
    override func setupViewCellFromFriend() {
        super.setupViewCellFromFriend()
    }
    
    override func setupContentCell() {
        super.setupContentCell()

        let url = messageModel!.content!
        
        // load image from url
        let imgLoad = ImageLoading()
        imgLoad.loadingImageAndCaching(
            target: stickerImageView,
            with: url,
            placeholder: nil,
            progressHandler: nil) { (error) in
            if error != nil {
                print("Error: ", error!)
                return
            }
 
            self.layoutIfNeeded()
        }
    }
    
    class func cellHeight(_ message: Message) -> CGFloat {
        return 130
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stickerImageView.image = nil
        stickerImageView.kf.cancelDownloadTask()
    }
    
    @objc func bubbleImagePressed(sender: UITapGestureRecognizer) {
        delegate?.cellDidTapSticker(self)
        delegate?.cellDidTap(self)
    }
}
