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

        navigationBar.barTintColor = UIColor.white
        navigationBar.backgroundColor = UIColor.white
        navigationBar.shadowImage = UIImage()
        navigationBar.layer.borderWidth = 0
        navigationItem.hidesBackButton = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
