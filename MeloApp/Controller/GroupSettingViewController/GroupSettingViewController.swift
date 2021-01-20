//
//  GroupSettingViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import UIKit

class GroupSettingViewController: UIViewController {

    @IBOutlet weak var customNav: NavigationBarNormal!
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var iconImageVideo: UIView!
    @IBOutlet weak var imageVideoStackView: UIStackView!
    
    @IBOutlet weak var iconTheme: UIView!
    @IBOutlet weak var themeStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        iconTheme.layer.cornerRadius = iconTheme.bounds.height / 2
        iconImageVideo.layer.cornerRadius = iconImageVideo.bounds.height / 2
        
        let tapTheme = UITapGestureRecognizer(target: self, action: #selector(handleThemeTapped))
        let tapImageVideo = UITapGestureRecognizer(target: self, action: #selector(handleImageVideoTapped))
        
        themeStackView.addGestureRecognizer(tapTheme)
        imageVideoStackView.addGestureRecognizer(tapImageVideo)
    }
    
    @objc func handleThemeTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc func handleImageVideoTapped(_ sender: UITapGestureRecognizer) {
        
    }
}
