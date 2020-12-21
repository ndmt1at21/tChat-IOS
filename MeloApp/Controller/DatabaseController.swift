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
                let user = User(
                    uid: userUID,
                    name: userData["name"] as! String,
                    email: userData["email"] as! String,
                    profileImage: userData["profileImage"] as? String,
                    friends: userData["friends"] as? [StringUID],
                    friendRequests: userData["friendRequests"] as? [StringUID]
                )
                
                return completion(user)
            }
            
            return completion(nil)
        }
    }
}
