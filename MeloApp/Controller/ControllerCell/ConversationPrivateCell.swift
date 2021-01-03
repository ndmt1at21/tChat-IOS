//
//  ConversationPrivateCell.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class ConversationPrivateCell: UITableViewCell {

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var recentMessage: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var seenImageCover: UIImageView!
    
    var group: Group? {
        didSet {
            if group != nil {
               
            }
        }
    }
    
    lazy var onlineCircleImage: UIView = {
        let circle = UIView()
        circle.layer.cornerRadius = circle.frame.height / 2
        circle.layer.borderWidth = 2
        circle.backgroundColor = .systemGreen
        
        return circle
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setupCell()
    }

    private func setupCell() {
        imageCover.layer.cornerRadius = imageCover.frame.height / 2
        seenImageCover.layer.cornerRadius = imageCover.frame.height / 2
    
        onlineCircleImage.frame = CGRect(x: imageCover.frame.width - 5, y: imageCover.frame.height - 5, width: 10, height: 10)
        
        imageCover.addSubview(onlineCircleImage)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
