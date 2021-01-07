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
    @IBOutlet weak var contentVIew: UIView!
    
    var userModel: User? {
        didSet {
            setupContentCell()
            layoutIfNeeded()
        }
    }
    
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

        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupOnlineCircle()
    }
    
    private func setupOnlineCircle() {
        onlineCircleImage.frame = CGRect(
            x: imageCover.frame.width - 15,
            y: imageCover.frame.height - 12,
            width: 15,
            height: 15
        )
        onlineCircleImage.image = UIImage(systemName: "circle.fill")
        onlineCircleImage.tintColor = .green
        onlineCircleImage.backgroundColor = .white
        onlineCircleImage.layer.borderWidth = 3
        onlineCircleImage.layer.borderColor = UIColor.white.cgColor
        onlineCircleImage.isHidden = true
        
        imageCover.addSubview(onlineCircleImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageCover.layer.cornerRadius = imageCover.frame.height / 2
        onlineCircleImage.layer.cornerRadius = onlineCircleImage.frame.height / 2
        onlineCircleImage.layer.masksToBounds = true
    }
    
    private func setupContentCell() {
        name.text = userModel?.name!
        
        let imgLoading = ImageLoading()
        imgLoading.loadingImageAndCaching(
            target: imageCover,
            with: userModel?.profileImage,
            placeholder: nil,
            progressHandler: nil) { (error) in
            if error != nil {
                print("Error:", error!)
                return
            }
            
            self.layoutIfNeeded()
        }
        
        UserActivity.observeUserActivity(userUID: userModel!.uid!) { (isActivity) in
            if isActivity {
                self.isOnline = true
            } else {
                self.isOnline = false
            }
        }
    }
}
