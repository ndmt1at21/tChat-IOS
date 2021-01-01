//
//  CollectionViewCell.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

class PageControlCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var topBarLine: UIView!
    
    var stickerModel: Sticker? = nil {
        didSet {
            guard let sticker = stickerModel else { return }
            
            if sticker.type! == .emoji {
                thumbnail.isHidden = true
                label.isHidden = false
                label.text = sticker.content
            } else {
                thumbnail.isHidden = false
                label.isHidden = true
                
                let imageLoading = ImageLoading()
                imageLoading.loadingImageAndCaching(
                    target: thumbnail,
                    with: sticker.content,
                    placeholder: nil,
                    progressHandler: nil) { (error) in
                    if error != nil {
                        print(error!)
                    }
                    self.thumbnail.stopAnimating()
                }
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                DispatchQueue.main.async {
                    self.view.backgroundColor = .systemGray5
                    self.topBarLine.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    self.view.backgroundColor = .white
                    self.topBarLine.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topBarLine.isHidden = true
    }
    
    override func prepareForReuse() {
        thumbnail.kf.cancelDownloadTask()
        self.view.backgroundColor = .white
        self.topBarLine.isHidden = true
    }
}
