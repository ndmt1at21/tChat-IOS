//
//  NavigationBarController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class NavigationBarController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationBar.barTintColor = UIColor.white
        navigationBar.backgroundColor = UIColor.white
        navigationBar.layer.borderWidth = 0
        navigationItem.hidesBackButton = true
       

        navigationBar.shadow(0, 3, 4, UIColor.systemGray6.cgColor)

        navigationBar.clipsToBounds = false
        navigationBar.shadowImage = UIImage()
    }
}
