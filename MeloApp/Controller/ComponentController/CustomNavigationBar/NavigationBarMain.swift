//
//  NavigationBarChatLog.swift
//  MeloApp
//
//  Created by Minh Tri on 1/2/21.
//

import UIKit

@objc protocol NavigationBarMainDelegate {
    @objc optional func navigationBar(_ naviagtionBarMain: NavigationBarMain, firstRightPressed sender: UIButton)
    @objc optional func navigationBar(_ naviagtionBarMain: NavigationBarMain, secondRightPressed sender: UIButton)
    @objc optional func navigationBar(_ naviagtionBarMain: NavigationBarMain, userImagePressed sender: UITapGestureRecognizer)
}

@IBDesignable
class NavigationBarMain: UIView {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstRightButton: UIButton!
    @IBOutlet weak var secondRightButton: UIButton!
    
    weak var delegate: NavigationBarMainDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadingView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadingView()
        setupView()
    }

    
    private func loadingView() {
        guard let view = self.loadViewFromNib(nibName: "NavigationBarMain") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        userImage.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImage.layer.cornerRadius = userImage.frame.height / 2
        firstRightButton.layer.cornerRadius = firstRightButton.frame.height / 2
        secondRightButton.layer.cornerRadius = secondRightButton.frame.height / 2
    }
    
    @IBAction private func firstRightButtonPressed(_ sender: UIButton) {
        delegate?.navigationBar?(self, firstRightPressed: sender)
    }
    
    @IBAction private func secondRightButtonPressed(_ sender: UIButton) {
        delegate?.navigationBar?(self, secondRightPressed: sender)
    }
    
   @objc private func userImageTapped(_ sender: UITapGestureRecognizer) {
    delegate?.navigationBar?(self, userImagePressed: sender)
    }
}
