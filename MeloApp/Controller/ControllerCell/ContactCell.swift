//
//  ContactCell.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit
import MaterialComponents

class ContactCell: MDCBaseCell {

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
}
