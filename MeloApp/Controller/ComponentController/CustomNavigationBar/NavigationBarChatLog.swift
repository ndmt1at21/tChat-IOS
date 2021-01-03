//
//  NavigationBarChatLog.swift
//  MeloApp
//
//  Created by Minh Tri on 1/2/21.
//

import UIKit
import MaterialComponents

protocol NavigationBarChatLogDelegate: class {
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, backPressed sender: UIButton)
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, infoPressed sender: UIButton)
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, groupInfoViewPressed sender: UITapGestureRecognizer)
}

@IBDesignable
class NavigationBarChatLog: UIView {
    
    @IBOutlet weak var backButton: MDCButton!
    
    @IBOutlet weak var groupInfoView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var activityHistory: UILabel!
    
    @IBOutlet weak var infoButton: MDCButton!
    
    weak var delegate: NavigationBarChatLogDelegate?
    
    lazy var activityCircle: UIView = {
        let circleView = UIView()
        circleView.layer.cornerRadius = circleView.bounds.height / 2
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.white.cgColor
        circleView.backgroundColor = .systemGreen
        
        return circleView
    }()
    
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
        guard let view = self.loadViewFromNib(nibName: "NavigationBarChatLog") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupView() {
        // circle actitciry
        let imgGroupSize = groupImage.bounds
        activityCircle.frame = CGRect(
            x: imgGroupSize.width - 5,
            y: imgGroupSize.height - 5,
            width: imgGroupSize.width,
            height: imgGroupSize.height
        )
        
        activityCircle.isHidden = true
    
        // tap group info view
        let tap = UITapGestureRecognizer(target: self, action: #selector(groupInfoViewTapped))
        groupInfoView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        groupImage.layer.cornerRadius = groupImage.frame.height / 2
    }
    
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.delegate?.navigationBar(self, backPressed: sender)
        }
    }
    
    @IBAction private func infoButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.delegate?.navigationBar(self, infoPressed: sender)
        }
    }
    
    @objc private func groupInfoViewTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.navigationBar(self, groupInfoViewPressed: sender)
    }
}
