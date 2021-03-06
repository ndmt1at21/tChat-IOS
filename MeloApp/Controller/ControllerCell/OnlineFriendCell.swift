//
//  OnlineFriendCell.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class OnlineFriendCell: UITableViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var onlineCircleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        imageCover.layer.cornerRadius = imageCover.frame.height / 2
    
        onlineCircleImage.frame = CGRect(x: imageCover.frame.width - 5, y: imageCover.frame.height - 5, width: 10, height: 10)
        
        imageCover.addSubview(onlineCircleImage)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
