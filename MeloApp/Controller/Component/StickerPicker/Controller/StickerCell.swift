//
//  StickerCell.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

protocol StickerCellDelegate : class {
    func stickerLongPressed(_ stickerCell: StickerCell)
}

class StickerCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var stickerImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    weak var delegate: StickerCellDelegate?
    
    var stickerModel: Sticker? {
        didSet {
            guard let safeSticker = stickerModel else { return }
            
            if safeSticker.type! == .emoji {
                label.isHidden = false
                stickerImage.isHidden = true
                label.text = safeSticker.content
            } else {
                label.isHidden = true
                stickerImage.isHidden = false
                
                let imageLoading = ImageLoading()
                imageLoading.loadingImageAndCaching(
                    target: stickerImage,
                    with: safeSticker.content,
                    placeholder: nil,
                    progressHandler: nil) { (error) in
                    if error != nil {
                        print("Error: ", error!)
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.isHidden = true
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        view.addGestureRecognizer(longTap)
    }
    
    override func prepareForReuse() {
        stickerImage.kf.cancelDownloadTask()
    }
    
    @objc func handleLongTap(_ sender: UILongPressGestureRecognizer) {
        delegate?.stickerLongPressed(self)
    }
}
