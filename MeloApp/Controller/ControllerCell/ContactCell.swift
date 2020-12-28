//
//  ContactCell.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var containerImageCover: UIView!
    
    var onlineCircleImage = UIImageView()
    
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
                    print(self.onlineCircleImage.isHidden)
                }
               
            } else {
                DispatchQueue.main.async {
                    self.onlineCircleImage.isHidden = false
                    print(self.onlineCircleImage.isHidden)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        imageCover.layer.cornerRadius = imageCover.frame.height / 2
        
        setupOnlineCircle()
      
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
        onlineCircleImage.layer.cornerRadius = onlineCircleImage.frame.height / 2
        onlineCircleImage.layer.masksToBounds = true
        
        containerImageCover.addSubview(onlineCircleImage)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            onlineCircleImage.layer.borderColor = UIColor.systemGray6.cgColor
            contentView.backgroundColor = UIColor.systemGray6
        } else {
            onlineCircleImage.layer.borderColor = UIColor.white.cgColor
            contentView.backgroundColor = UIColor.white
        }
    }
}
