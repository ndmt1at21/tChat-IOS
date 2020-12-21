//
//  UserAcitivity.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Firebase

class UserActivity {
    static func updateCurrentUserActivity(_ onlineStatus: Bool) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(currentUser.uid)
        
        userRef.child("isOnline").setValue(onlineStatus)
        userRef.child("isOnline").onDisconnectSetValue(false)
        userRef.child("lastLogin").setValue(Date().milisecondSince1970)
    }
    
    static func observeUserActivity(userUID: StringUID, completion: @escaping (_ isOnline: Bool) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users").child(userUID).observe(.value) { (snap) in
            let value = snap.value as? NSDictionary
            return completion(value?["isOnline"] as? Bool ?? false)
        }
    }
    
    static func setCurrentUserTyping(_ isTyping: Bool, groupID: StringUID) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference()
        let userRef = ref.child("usersAction").child(groupID)
        userRef.setValue(currentUser.uid)
    }
    
    static func getUsersTyping(userID: StringUID, groupID: StringUID) -> [StringUID] {
        let ref = Database.database().reference()
        let userRef = ref.child("usersAction").child(groupID)
        
        userRef.observe(.value) { (snap) in
            print(snap)
        }
        
        return []
    }
    
    static func removeCurrentUserTyping(userID: StringUID, groupID: StringUID) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let ref = Database.database().reference()
        ref.child("usersAction").child(groupID).child(currentUser.uid).removeValue()
        
    }
}
