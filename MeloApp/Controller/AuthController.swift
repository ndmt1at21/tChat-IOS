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
    var currentUser: User? = nil
    
    private init() {}
    
    func setupCurrentUser(completion: @escaping (_ user: User?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil)
        }
        
        self.listenChangeCurrentUser { (user) in
            if user != nil {
                self.currentUser = user
            }
        }
       
        Firestore.firestore().collection("users").document(currentUser.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("Error: ", error!.localizedDescription)
                return completion(nil)
            }

            if let data = snapshot?.data() {
                let user = User(uid: currentUser.uid, dictionary: data)
                self.currentUser = user

                return completion(user)
            }
        }
    }
    
    func listenChangeCurrentUser(completion: @escaping (_ currentUser: User?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil)
        }
        
        Firestore.firestore().collection("users").document(currentUser.uid).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("Error: ", error!.localizedDescription)
                return completion(nil)
            }

            if let data = snapshot?.data() {
                let user = User(uid: currentUser.uid, dictionary: data)
                return completion(user)
            }
        }
    }
    
    func handleLogin(email: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if authResult?.user.uid != nil {
                return completion(nil)
            }
            
            if let err = error as NSError? {
                switch err.code {
                case AuthErrorCode.userNotFound.rawValue:
                    return completion("Email không tồn tại")
                    
                case AuthErrorCode.networkError.rawValue:
                    return completion("Lỗi đường truyền")
                    
                case AuthErrorCode.wrongPassword.rawValue:
                    return completion("Sai tên đăng nhập hoặc mật khẩu")
                    
                default:
                    return completion("Lỗi máy chủ")
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
                
                case AuthErrorCode.networkError.rawValue:
                    return completion("Lỗi đường truyền")
                    
                default:
                    return completion("Lỗi máy chủ")
                }
            }
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

