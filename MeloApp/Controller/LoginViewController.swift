//
//  ViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/14/20.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAuth


class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
      
        loginButton.border(.all, 0, UIColor.clear.cgColor, 15)
        registerButton.border(.all, 0, UIColor.clear.cgColor, 15)
        
        loginButton.addGradientLayer(colors: [UIColor(named: "primaryBlue")!.cgColor, UIColor(named: "lightBlue")!.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y:0), locations: [0, 1])
        
        registerButton.addGradientLayer(colors: [UIColor.systemGray5.cgColor, UIColor.systemGray6.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y:0), locations: [0, 1])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {

        var errorMsgEmail = ""
        var errorMsgPwd = ""
        
        // Verify email
        if let email = emailTextField.text {
            if !email.isValidEmail() {
               errorMsgEmail = "Email không đúng định dạng"
            } else {
                // Login
            }
        } else {
            errorMsgEmail = "Bạn quên chưa nhập email ^^"
        }
        
        // Verify password
        if passwordTextField.text?.count == 0 {
            errorMsgPwd = "Bạn quên chưa nhập mật khẩu ^^"
        } else if passwordTextField.text!.count < 8 {
            errorMsgPwd = "Mật khẩu phải lớn hơn 8 ký tự"
        }
        
        if errorMsgEmail.count > 0 {
            emailTextField.errorMessage = errorMsgEmail
            return
        }

        self.passwordTextField.errorMessage = errorMsgPwd
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let textField = sender as? SkyFloatingLabelTextField {
            textField.errorMessage = ""
        }
    }
}
