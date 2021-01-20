//
//  HeaderUserSetting.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import UIKit

protocol HeaderUserSettingCellDelegate: class {
    func cellDidTap(_ header: HeaderUserSettingCell)
}

class HeaderUserSettingCell: UICollectionReusableView {

    @IBOutlet weak var containerAvatarView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var constraintUserNameTopAvatar: NSLayoutConstraint!
    
    weak var delegate: HeaderUserSettingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerAvatarView.isUserInteractionEnabled = true
        containerAvatarView.layer.cornerRadius = containerAvatarView.bounds.height / 2
        containerAvatarView.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped))
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(tap)
    }
    
    func viewHeight() -> CGFloat {
        return avatar.bounds.height + userName.bounds.height + constraintUserNameTopAvatar.constant
    }
    
    @objc private func handleAvatarTapped(_ sender: UITapGestureRecognizer) {
        delegate?.cellDidTap(self)
    }
}
