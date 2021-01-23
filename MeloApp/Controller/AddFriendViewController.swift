//
//  AddFriendViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 1/6/21.
//

import UIKit
import SkyFloatingLabelTextField
import MaterialComponents
import Firebase

class AddFriendViewController: UIViewController {

    @IBOutlet weak var customNavBar: NavigationBarNormal!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sendButton: MDCButton!
    
    
    lazy var loadingAnimation: LoadingIndicator = {
        let loading = LoadingIndicator(frame: .zero)
        loading.isTurnBlurEffect = true
        loading.colorIndicator = .blue
        
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupSendButton()
        emailTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapViewScreen))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTapViewScreen(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
    }
    
    private func setupNavBar() {
        customNavBar.delegate = self
        customNavBar.titleLabel.text = "Thêm bạn bè"
        customNavBar.preferLarge = false
        
        customNavBar.backgroundColor = .white
        customNavBar.backButton.backgroundColor = .white
        customNavBar.backButton.inkColor = .systemGray5
    }
    
    private func setupSendButton() {
        sendButton.layer.cornerRadius = 10
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        emailTextField.resignFirstResponder()
        
        if let error = validateTextField() {
            self.emailTextField.errorMessage = error
            return
        }
        
        loadingAnimation.startAnimation()
        loadingAnimation.frame = view.bounds
        view.addSubview(loadingAnimation)
        
        let email = emailTextField.text!
        DatabaseController.checkUserExist(by: email) { (isExist) in
            
            if isExist {
                self.sendFriendRequest(to: email) { (error) in
                    self.loadingAnimation.stopAnimation()
                    self.loadingAnimation.removeFromSuperview()
                    
                    if error != nil {
                        self.emailTextField.errorMessage = "Không thể gửi lời mời lúc này"
                        return
                    }

                    self.emailTextField.titleLabel.text = "Gửi lời mời thành công".uppercased()
                }
            } else {
                self.loadingAnimation.stopAnimation()
                self.loadingAnimation.removeFromSuperview()
                
                self.emailTextField.errorMessage = "Email chưa dược đăng ký"
            }
        }
    }
    
    private func validateTextField() -> String? {
        guard let email = emailTextField.text else {
            return "Email là bắt buộc"
        }
        
        if !email.isValidEmail() {
            return "Email không đúng định dạng"
        }
        
        if let currentUser =  CurrentUser.shared.currentUser {
            if email == currentUser.email! {
                return "Không thể kết bạn chính mình :))"
            }
        }
        
        return nil
    }
    
    private func sendFriendRequest(to email: String, completion: @escaping (_ error: String?) -> Void) {
        
        guard let currentUser =  CurrentUser.shared.currentUser else { return }
        
        DatabaseController.getUserByEmail(email: email) { (user) in
            if user == nil { return completion(nil) }
            
            Firestore.firestore().collection("users").document(user!.uid!).updateData(["friendRequests.\(currentUser.uid!)": true]) { (error) in
                return completion(error?.localizedDescription)
            }
        }
    }
}

extension AddFriendViewController: NavigationBarNormalDelegate {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton) {
        navigationController?.hero.isEnabled = true
        navigationController?.popViewController(animated: true)
    }
}

extension AddFriendViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextField.errorMessage = ""
    }
}
