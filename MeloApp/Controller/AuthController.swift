//
//  AuthController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Foundation
import Firebase

class AuthController {
    static let shared = AuthController()
    private var isFirstFetch = true
    var currentUser: User? = nil
    
    func setupCurrentUser(completion: @escaping (_ user: User?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil)
        }
        
        if !isFirstFetch {
            return completion(self.currentUser)
        }
        
        Firestore.firestore().collection("users").document(currentUser.uid).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("Error: ", error!.localizedDescription)
                return completion(nil)
            }
            
            if let data = snapshot?.data() {
                self.isFirstFetch = false
                let user = User(uid: currentUser.uid, dictionary: data)
                self.currentUser = user
                
                return completion(user)
            }
        }
    }
    
    private init() {}
    
    func handleLogin(email: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if authResult?.user.uid != nil {
                print("authresulttight", authResult?.user.uid)
                return completion(nil)
            }
            
            if let err = error as NSError? {
                switch err.code {
                case AuthErrorCode.userNotFound.rawValue:
                    return completion("Email không tồn tại")
                default:
                    return completion("Sai tên đăng nhập hoặc mật khẩu")
                }
            }
        }
    }
    
    func handleRegister(email: String, password: String, completion: @escaping (_ err: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if authResult?.user.uid != nil {
                return completion(nil)
            }
            
            if let err = error as NSError? {
                switch err.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    return completion("Email của bạn đã được sử dụng")
                    
                case AuthErrorCode.invalidEmail.rawValue:
                    return completion("Email không đúng định dạng")
                
                case AuthErrorCode.weakPassword.rawValue:
                    return completion("Mật khẩu quá yếu")
                    
                default:
                    return completion("Lỗi đường truyền")
                }
            }
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print(err)
        }
    }
}

