//
//  CustomizeChatCell.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import UIKit
import MaterialComponents

class CustomizeThemeChatCell: MDCBaseCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        containerView.layer.cornerRadius = 10
        image.layer.cornerRadius = image.bounds.height / 2
    }
}
