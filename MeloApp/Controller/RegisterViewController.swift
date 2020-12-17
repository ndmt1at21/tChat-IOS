//
//  RegisterViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/16/20.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAuth

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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        var errorMsgEmail = ""
        var errorMsgPwd = ""
        var errorMsgName = ""
        var errorMsgRetypePwd = ""
        
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
        
        // Verify name
        if nameTextField.text?.count == 0 {
            errorMsgName = "Bạn chưa nhập tên"
        } else if nameTextField.text!.count < 5 {
            errorMsgName = "Đặt tên thật để bạn bè dễ nhận ra"
        }
        
        // Verify retype password
        if let pwdRetype = retypePasswordTextField.text, let pwd = passwordTextField.text {
            if pwdRetype != pwd {
                errorMsgRetypePwd = "Mật khẩu xác nhận không khớp"
            }
        }
        
        if errorMsgEmail.count > 0 {
            emailTextField.errorMessage = errorMsgEmail
            return
        } else if errorMsgName.count > 0 {
            nameTextField.errorMessage = errorMsgName
            return
        } else if errorMsgPwd.count > 0 {
            passwordTextField.errorMessage = errorMsgPwd
            return
        } else if errorMsgRetypePwd.count > 0 {
            retypePasswordTextField.errorMessage = errorMsgRetypePwd
        }
        
        handleRegister(email: emailTextField.text!, password: passwordTextField.text!) { (err) in
            if err != nil {
                self.emailTextField.errorMessage = err
                self.emailTextField.textErrorColor = self.emailTextField.textColor
                return
            }
            
            self.performSegue(withIdentifier: K.segueID.registerToConversation, sender: self)
        }
        
    }
    
    func handleRegister(email: String, password: String, completion: @escaping (_ err: String?) -> Void) {
        
        let loadingIndicator = LoadingIndicator()
        loadingIndicator.startAnimation()
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, err) in
            loadingIndicator.stopAnimation()
            if authResult?.user.uid != nil {
                return completion(nil)
            }
            return completion("Đăng ký tài khoản không thành công")
        }
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if let textField = sender as? SkyFloatingLabelTextField {
            textField.errorMessage = ""
        }
    }
}
