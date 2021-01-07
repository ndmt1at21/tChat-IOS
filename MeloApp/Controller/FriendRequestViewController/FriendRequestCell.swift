//
//  FriendRequestCell.swift
//  MeloApp
//
//  Created by Minh Tri on 1/6/21.
//

import UIKit
import MaterialComponents

protocol FriendRequestCellDelegate: class {
    func acceptDidPressed(_ cell: FriendRequestCell, userUID: StringUID)
    func deleteDidPressed(_ cell: FriendRequestCell, userUID: StringUID)
}

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var acceptButton: MDCButton!
    @IBOutlet weak var deleteButton: MDCButton!
    
    weak var delegate: FriendRequestCellDelegate?
    
    var userModel: User? {
        didSet {
            setupFriendInfo()
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        userAvatar.layer.masksToBounds = true
        acceptButton.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 10
    }
    
    private func setupFriendInfo() {
        userName.text = userModel!.name
    
        let imgLoading = ImageLoading()
        imgLoading.loadingImageAndCaching(target: userAvatar, with: userModel?.profileImage, placeholder: nil, progressHandler: nil) { (error) in
            if error != nil {
                print("Error:", error!)
                return
            }
            
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        delegate?.acceptDidPressed(self, userUID: userModel!.uid!)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deleteDidPressed(self, userUID: userModel!.uid!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userAvatar.image = nil
    }
}
