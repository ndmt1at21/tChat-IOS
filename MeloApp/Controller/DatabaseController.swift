//
//  DatabaseController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Foundation
import Firebase

class DatabaseController {
    
    static func getUser(userUID: StringUID, completion: @escaping (_ user: User?) -> Void) {
        
        Firestore.firestore().collection("users").document(userUID).getDocument { (userDoc, error) in
            
            if error != nil {
                return completion(nil)
            }
            
            if let userData = userDoc?.data() {
                let user = User(uid: userUID, dictionary: userData)
                return completion(user)
            }
            
            return completion(nil)
        }
    }
}
