//
//  BubbleChatFromFriend.swift
//  MeloApp
//
//  Created by Minh Tri on 12/20/20.
//

import UIKit

class BubbleChatFromFriend: UITableViewCell {

    
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageCover.layer.cornerRadius = imageCover.frame.height / 2
        
        if bubbleView.frame.height < 50 {
            bubbleView.layer.cornerRadius = bubbleView.frame.height / 2
        } else {
            bubbleView.layer.cornerRadius = 20
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
