//
//  ConversationPrivateCell.swift
//  MeloApp
//
//  Created by Minh Tri on 1/22/21.
//

import UIKit
import MaterialComponents

class ConversationPrivateCell: MDCBaseCell {

    @IBOutlet weak var containerImageCover: UIView!
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var recentMessage: UILabel!
    
    var onlineCircleImage = UIImageView()
    
    var groupModel: Group? {
        didSet {
            setupContentCell()
            layoutIfNeeded()
        }
    }
    
    private var isOnlineValue = false
    var isOnline: Bool {
        get {
            return isOnlineValue
        }
        
        set {
            isOnlineValue = newValue
            
            if !isOnlineValue {
                DispatchQueue.main.async {
                    self.onlineCircleImage.isHidden = true
                }
               
            } else {
                DispatchQueue.main.async {
                    self.onlineCircleImage.isHidden = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupOnlineCircle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageCover.layer.cornerRadius = imageCover.bounds.height / 2
        imageCover.layer.masksToBounds = true
    }
    
    private func setupOnlineCircle() {
        onlineCircleImage.frame = CGRect(
            x: containerImageCover.frame.width - 15,
            y: containerImageCover.frame.height - 12,
            width: 15,
            height: 15
        )
        onlineCircleImage.image = UIImage(systemName: "circle.fill")
        onlineCircleImage.tintColor = .green
        onlineCircleImage.backgroundColor = .white
        onlineCircleImage.layer.borderWidth = 3
        onlineCircleImage.layer.borderColor = UIColor.white.cgColor
        onlineCircleImage.isHidden = true
        
        containerImageCover.addSubview(onlineCircleImage)
    }
    
    private func setupContentCell() {
        
        groupModel?.getGroupImageAvatar(completion: { (imageUrl) in
            // image group
            let imgLoading = ImageLoading()
            imgLoading.loadingImageAndCaching(
                target: self.imageCover,
                with: imageUrl,
                placeholder: nil,
                progressHandler: nil) { (error) in
                if error != nil {
                    print("Error:", error!)
                    return
                }
            }
        })
        
        
        
        // name group
        groupModel?.getNameGroup(completion: { (name) in
            self.nameGroup.text = name
        })
        
        // message
        if let message = groupModel?.recentMessage?.message {
            switch message.type {
            case .image:
                recentMessage.text = "[Hình ảnh]"
            case .video:
                recentMessage.text = "[Video]"
            case .sticker:
                recentMessage.text = "[Sticker]"
            case .text:
                nameGroup.text = message.content
            default:
                nameGroup.text = ""
            }
        }
    }
}
