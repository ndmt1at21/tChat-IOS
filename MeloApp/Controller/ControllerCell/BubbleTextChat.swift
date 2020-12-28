//
//  BubbleChatFromFriend.swift
//  MeloApp
//
//  Created by Minh Tri on 12/20/20.
//

import UIKit

class BubbleTextChat: BubbleBaseChat {
    
    @IBOutlet weak var message: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        message.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        message.textContainer.lineFragmentPadding = .zero
        progressBar.isHidden = true
        
        if bubbleView.frame.height < 50 {
            bubbleView.layer.cornerRadius = bubbleView.frame.height / 2
        } else {
            bubbleView.layer.cornerRadius = 20
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(textViewTaped))
        bubbleView.addGestureRecognizer(tap)
    }

    override func setupViewCellFromMe() {
        super.setupViewCellFromMe()

        bubbleView.backgroundColor = K.primaryColor
        message.textColor = .white
    }
    
    override func setupViewCellFromFriend() {
        super.setupViewCellFromFriend()
 
        bubbleView.backgroundColor = .systemGray4
        message.textColor = .black
    }

    override func setupContentCell() {
        super.setupContentCell()
        
        message.text = messageModel?.content
        message.sizeToFit()
    }
    
    class func cellHeight(_ message: Message) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func textViewTaped(sender: UITapGestureRecognizer) {
        delegate?.cellDidTapText(self)
    }
}
