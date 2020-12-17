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

        handleLogin(email: emailTextField.text!, password: passwordTextField.text!) { (err) in
            if err != nil {
                self.emailTextField.errorMessage = err
                self.emailTextField.textErrorColor = self.emailTextField.textColor
                return
            }
            
            self.performSegue(withIdentifier: K.segueID.loginToConversation, sender: self)
        }
    }
    
    func handleLogin(email: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        
        let loadingIndicator = LoadingIndicator()
        loadingIndicator.startAnimation()
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            loadingIndicator.stopAnimation()
            if authResult?.user.uid != nil {
                return completion(nil)
            }
            
            return completion("Sai tên đăng nhập hoặc mật khẩu")
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let textField = sender as? SkyFloatingLabelTextField {
            textField.errorMessage = ""
        }
    }
}
