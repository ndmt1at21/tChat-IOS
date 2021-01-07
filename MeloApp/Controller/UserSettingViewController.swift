//
//  UserSettingViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 1/7/21.
//

import UIKit

class UserSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        AuthController.shared.handleLogout()
            
        // remove observe
        UserActivity.updateCurrentUserActivity(false)
        
        // pop to root view controllelr
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.rootNavigationController)
        
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
}
