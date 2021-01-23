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
    
    private init() {}
    
    func handleLogin(email: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
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
            return completion(nil)
        }
    }
    
    func handleRegister(email: String, password: String, completion: @escaping (_ err: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
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
            
            return completion(nil)
        }
    }
    
    func handleLogout() {
        do {
            UserActivity.updateCurrentUserActivity(false)
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

