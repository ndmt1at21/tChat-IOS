//
//  RegisterViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/16/20.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var retypePasswordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerButton.layoutIfNeeded()
        registerButton.border(.all, 0, UIColor.clear.cgColor, 10)
        
        registerButton.addGradientLayer(colors: [UIColor(named: "primaryBlue")!.cgColor, UIColor(named: "lightBlue")!.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y:0), locations: [0, 1])
    
    }
    
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let textField = sender as? SkyFloatingLabelTextField {
            textField.errorMessage = ""
        }
    }
