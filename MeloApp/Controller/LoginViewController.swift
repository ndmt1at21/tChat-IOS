//
//  ViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/14/20.
//

import UIKit
import SkyFloatingLabelTextField
import MaterialComponents

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
   
    @IBOutlet weak var loginButton: MDCButton!
    @IBOutlet weak var registerButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
      
        loginButton.border(.all, 0, UIColor.clear.cgColor, 15)
        registerButton.border(.all, 0, UIColor.clear.cgColor, 15)
        
        loginButton.addGradientLayer(colors: [UIColor(named: "primaryBlue")!.cgColor, UIColor(named: "lightBlue")!.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y:0), locations: [0, 1])

        loginButton.rippleColor = UIColor(named: "darkBlue")

        registerButton.addGradientLayer(colors: [UIColor.systemGray5.cgColor, UIColor.systemGray6.cgColor], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y:0), locations: [0, 1])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {

        var errorMsgEmail = ""
        var errorMsgPwd = ""
        
        // Verify email
        if let email = emailTextField.text {
            if !email.isValidEmail() {
               errorMsgEmail = "Email không đúng định dạng"
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
        } else if errorMsgPwd.count > 0 {
            self.passwordTextField.errorMessage = errorMsgPwd
            return
        }

        let loadingIndicator = LoadingIndicator()
        loadingIndicator.startAnimation()
        
        AuthController.shared.handleLogin(email: emailTextField.text!, password: passwordTextField.text!) { (err) in
            
            loadingIndicator.stopAnimation()
            
            if err != nil {
                self.emailTextField.errorMessage = err
                self.emailTextField.textErrorColor = self.emailTextField.textColor
                return
            }
            
            UserActivity.updateCurrentUserActivity(true)
            self.performSegue(withIdentifier: K.segueID.loginToConversation, sender: self)
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let textField = sender as? SkyFloatingLabelTextField {
            textField.errorMessage = ""
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
}
