//
//  DatabaseController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import Foundation
import Firebase

class DatabaseController {
    
    static func checkUserExist(by email: String, completion: @escaping (_ isExist: Bool) -> Void) {
    
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email).getDocuments(completion: { (querySnapshot, error) in
            
            if error != nil {
                return completion(false)
            }
            
            if querySnapshot!.count > 0 { return completion(true) }
            return completion(false)
        })
    }
    
    static func getUserByEmail(email: String, completion: @escaping (_ user: User?) -> Void) {
        
        Firestore.firestore().collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if error != nil {
                return completion(nil)
            }
            
            if let docSnap = querySnapshot?.documents.first {
                let user = User(uid: docSnap.documentID, dictionary: docSnap.data())
                return completion(user)
            }
            
            return completion(nil)
        }
    }
    
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
    
    static func getMessages(from messageUID: StringUID?, in groupUID: StringUID, limit toLast: Int, completion: @escaping (_ messages: [Message]) -> Void) {
        
        let refMessage = Firestore.firestore()
            .collection("messages")
            .document(groupUID)
            .collection("messages")
    
        var messageQuery: Query = refMessage.order(by: "sendAt").limit(to: toLast)

        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        if messageUID != nil {

            refMessage.document(messageUID!).getDocument { (snapshot, error) in
                if error != nil {
                    return completion([])
                }

                messageQuery = messageQuery.end(beforeDocument: snapshot!)
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global()) {
            messageQuery.getDocuments { (snapshot, error) in
                if error != nil {
                    return completion([])
                }
                
                var addedMessages: [Message] = []
                
                snapshot?.documents.forEach({ (docSnapshot) in
                    let data = docSnapshot.data()
                    
                    let message = Message(
                        uid: docSnapshot.documentID,
                        dataFromServer: data
                    )
                    
                    addedMessages.append(message)
                })
                
                return completion(addedMessages)
            }
        }
    }
    
    static func sendMessage(message: Message, to groupUID: StringUID, completion: @escaping (_ documentID: StringUID?, _ error: String?) -> Void) {
        guard let _ = CurrentUser.shared.currentUser else { return }
    
        // set new message
        let ref = Firestore.firestore()
            .collection("messages").document(groupUID)
            .collection("messages").document()
        
        ref.setData(message.dictionaryForSend()) { (error) in
            if error != nil {
                return completion(nil, error?.localizedDescription)
            }
            
            // update recent message group
            let recentMessage = RecentMessage(message, nil)
            
            Firestore.firestore()
                .collection("groups").document(groupUID)
                .updateData(["recentMessage" : recentMessage.dictionaryForSend()])
            return completion(ref.documentID, nil)
        }
        
        
    }
    
    static func updateMessage(_ messageUID: StringUID, _ groupUID: StringUID, fields: [String: Any]) {
        
        let ref = Firestore.firestore()
            .collection("messages").document(groupUID)
            .collection("messages").document(messageUID)
        
        ref.updateData(fields)
    }
    
    /// This function returns group  information
    ///
    /// ```
    /// getGroup("123456", completion block)
    /// ```
    /// Should use two get group > 2 members
    ///
    /// - Parameter groupUID: groupUID use to get group's information
    /// - Parameter completion: Completion block will execute when group have been successfully read
    /// - Parameter group: Group's infomation when group have been successfully read, or nil if group not exist
    static func getGroup(by groupUID: StringUID, completion: @escaping (_ group: Group?) -> Void) {
        
        let groupRef = Firestore.firestore().collection("groups").document(groupUID)
        
        groupRef.getDocument { (snapshot, error) in
            if let doc = snapshot?.data() {
                let group = Group(uid: snapshot!.documentID, dataFromServer: doc)
                return completion(group)
            }
            
            return completion(nil)
        }
    }
    
    /// This function get all theme in server
    ///
    /// - Parameter completion: Completion block will execute when themes have been successfully read
    /// - Parameter themes: array of themes in server
    static func getThemes(completion: @escaping (_ themes: [Theme]) -> Void) {
        let themeRef = Firestore.firestore().collection("themes")
        
        themeRef.getDocuments { (querySnap, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return completion([])
            }
            
            var themes: [Theme] = []
            querySnap?.documents.forEach({ (queryDocSnap) in
                let data = queryDocSnap.data()
                
                let theme = Theme(uid: queryDocSnap.documentID, dataFromServer: data)
                themes.append(theme)
            })
            
            return completion(themes)
        }
    }
    
    
    /// This function returns group information
    ///
    /// ```
    /// getGroup("123456", completion block)
    /// ```
    /// Should use two get group equal to 2 members
    ///
    /// - Parameter groupUID1: member1's uid
    /// - Parameter groupUID1: member2's uid
    /// - Parameter completion: Completion block will execute when group have been successfully read
    /// - Parameter group: Group's infomation when group have been successfully read, or nil if group not exist
    static func getGroup(by userUID1: StringUID, and userUID2: StringUID, completion: @escaping (_ group: Group?) -> Void) {
        
        let groupRef = Firestore.firestore().collection("groups")
        
        // Bug  ??
        let query = groupRef
            .whereField("members.\(userUID1)", isEqualTo: true)
            .whereField("members.\(userUID2)", isEqualTo: true)
        
        query.getDocuments { (querySnap, error) in
            if (error != nil) {
                print(error!.localizedDescription)
                return completion(nil)
            }
            
            if querySnap?.count == 0 {
                return completion(nil)
            }
            
            querySnap?.documents.forEach({ (queryDocSnap) in
                let doc = queryDocSnap.data()
                let group = Group(uid: queryDocSnap.documentID, dataFromServer: doc)
                
                if group.members!.count != 2 {
                    return completion(nil)
                } else {
                    return completion(group)
                }
            })
        }
    }
    
    /// This function create group
    ///
    /// ```
    /// createGroup(with ["123", "321", "112"], completion block)
    /// ```
    ///
    /// - Parameter usersUID: array of UserUIDs join group
    /// - Parameter completion: Completion block will execute when group have been successfully read
    /// - Parameter group: Group's infomation when group have been successfully create, or nil if group create fail
    static func createGroup(with usersUID: [StringUID], completion: @escaping (_ group: Group?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        if usersUID.count <= 1 { return completion(nil)}
        
        let groupRef = Firestore.firestore().collection("groups")
        
        var group = Group(
           createdBy: currentUser.uid,
           members: usersUID.reduce(into: [:], { (result, userUID) in
               result[userUID] = true
           }),
           recentMessage: nil,
            displayName: "test"
        )
        
        let ref = groupRef.document()
        ref.setData(group.dictionaryForSend()) { (error) in
           if error != nil {
               return completion(nil)
           }
           
           group.uid = ref.documentID
           return completion(group)
        }
    }
}
