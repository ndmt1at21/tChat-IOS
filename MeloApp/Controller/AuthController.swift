//
//  AuthController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Foundation
import FirebaseAuth

class AuthController {
    static func handleLogin(email: String, password: String, completion: @escaping (_ error: String?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            
            if authResult?.user.uid != nil {
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
    
    static func handleRegister(email: String, password: String, completion: @escaping (_ err: String?) -> Void) {
        
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
    
    static func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print(err)
        }
    }
}

