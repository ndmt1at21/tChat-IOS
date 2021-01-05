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
    
    static func observeFriends(from userUID: StringUID, completion: @escaping (_ friend: [User]) -> Void) {
        
        Firestore.firestore().collection("user").document(userUID).addSnapshotListener { (snapshot, error) in
            if error != nil {
                print("Error:", error!.localizedDescription)
                return completion([])
            }
            
            if let userData = snapshot?.data() {
                guard let friends = userData["friends"] as? [StringUID] else {
                    return completion([])
                }
                
                return completion([])
            }
        }
    }
    
    
    
    static func sendMessage(message: Message, to groupUID: StringUID, completion: @escaping (_ documentID: StringUID?, _ error: String?) -> Void) {
        guard let _ = AuthController.shared.currentUser else { return }
    
        let ref = Firestore.firestore()
            .collection("messages").document(groupUID)
            .collection("messages").document()
        
        ref.setData(message.dictionaryForSend()) { (error) in
            if error != nil {
                return completion(nil, error?.localizedDescription)
            }
            return completion(ref.documentID, nil)
        }
    }
    
    static func updateMessage(_ messageUID: StringUID, _ groupUID: StringUID, fields: [String: Any]) {
        
        let ref = Firestore.firestore()
            .collection("messages").document(groupUID)
            .collection("messages").document(messageUID)
        
        ref.updateData(fields)
    }
}
