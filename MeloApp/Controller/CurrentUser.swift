//
//  CurrentUser.swift
//  MeloApp
//
//  Created by Minh Tri on 1/22/21.
//

import UIKit
import Firebase

protocol CurrentUserDelegate: class {
    func incommingMessage(inGroup uid: StringUID, newMessage: Message)
    func incommingFriendRequest(user: User)
    func currentUserChange()
    func onlineStatusFriendChange(friend: StringUID, status: Bool)
}

class CurrentUser {
    static let shared = CurrentUser()
    var currentUser: User? = nil
    var friends: [StringUID: User] = [:]
    var groups: [StringUID: Group] = [:]
    var friendsRequests: [StringUID: User] = [:]
    var statusOnlineFriends: [StringUID: Bool] = [:]
    var isOnline: Bool = true
    
    private var listeners: [ListenerRegistration] = []
    private var delegates: [CurrentUserDelegate?] = []
    
    private init() {}
    
    func setupCurrentUser() {
        listenChangeUserAuth()
        listenChangeCurrentUser { (user) in
            self.currentUser = user
            
            self.delegates.forEach { (delegate) in
                delegate?.currentUserChange()
            }
            
            if user != nil {
                self.getFriends()
                self.getFriendsRequest()
                self.listenStatusOnlineFriends()
            }
        }
        
        UserActivity.updateCurrentUserActivity(true)
        listenChangeGroups()
    }
    
    func addDelegate(delegate: CurrentUserDelegate?) {
        if delegate != nil {
            delegates.append(delegate)
        }
    }
    
    func removeDelegate(delegate: CurrentUserDelegate?) {
        delegates.removeAll(where: { $0 === delegate })
    }
    
    private func listenChangeUserAuth() {
        guard let _ = Auth.auth().currentUser else {
            clear()
            return
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.clear()
            }
        }
    }
    
    private func listenChangeCurrentUser(completion: @escaping (_ currUser: User?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            clear()
            return completion(nil)
        }
        
        let listener = Firestore.firestore().collection("users").document(currentUser.uid).addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                print("Error: ", error!.localizedDescription)
                self.clear()
                return completion(nil)
            }
            
            if let data = snapshot?.data() {
                self.currentUser = User(uid: currentUser.uid, dictionary: data)
                return completion(self.currentUser)
            }
        }
        
        listeners.append(listener)
    }
    
    private func listenChangeGroups() {
        print("testsytsdsdgh")
        guard let currentUser = Auth.auth().currentUser else {
            clear()
            return
        }
        let listener = Firestore.firestore().collection("groups")
            .whereField("members.\(currentUser.uid)", isEqualTo: true)
            .addSnapshotListener(includeMetadataChanges: true, listener: { (querySnap, error) in

            if error != nil {
                print("Error:", error!.localizedDescription)
                return
            }
            
            let docsChange = querySnap?.documentChanges
            
            docsChange?.forEach({ (docChange) in
                let data = docChange.document.data()
                let uid = docChange.document.documentID
                let group = Group(uid: uid, dataFromServer: data)
                
                switch docChange.type {
                case .added:
                    self.groups[docChange.document.documentID] = group
                    
                    if let newRecentMess = self.groups[uid]?.recentMessage {
                        if newRecentMess.readBy == nil ||
                            !newRecentMess.readBy!.contains(where: { $0.key == currentUser.uid}) {
                        
                            self.delegates.forEach { (delegate) in
                                delegate?.incommingMessage(inGroup: uid, newMessage: newRecentMess.message)
                            }
                        }
                    }
                case .modified:
                    
                    if let oldRecentMess = self.groups[uid]?.recentMessage,
                       let newRecentMess = group.recentMessage {
                        
                        if oldRecentMess.message.uid != newRecentMess.message.uid {
                            self.delegates.forEach { (delegate) in
                                delegate?.incommingMessage(inGroup: uid, newMessage: newRecentMess.message)
                            }
                        }
                    }
                    
                    self.groups[docChange.document.documentID] = group
                    
                case .removed:
                    self.groups[docChange.document.documentID] = nil
                }
            })
        })
        
        listeners.append(listener)
    }
    
    private func getFriends() {
        if currentUser == nil || currentUser?.friends == nil { return }
        
        let friendUIDs = currentUser!.friends!.map{ $0.key }
        
        friendUIDs.forEach { (friendUID) in
            DatabaseController.getUser(userUID: friendUID) { (user) in
                if user != nil {
                    self.friends[user!.uid!] = user!
                }
            }
        }
    }
    
    private func getFriendsRequest() {
        if currentUser == nil || currentUser?.friends == nil { return }
        
        let userUIDs = currentUser!.friends!.map{ $0.key }
        
        userUIDs.forEach { (userUID) in
            DatabaseController.getUser(userUID: userUID) { (user) in
                if user != nil {
                    if self.friendsRequests[userUID] == nil {
                        self.delegates.forEach { (delegate) in
                            delegate?.incommingFriendRequest(user: user!)
                        }
                    }
                    self.friendsRequests[user!.uid!] = user!
                }
            }
        }
    }
    
    private func listenStatusOnlineFriends() {
        if currentUser == nil || currentUser?.friends == nil { return }
        
        let friends = currentUser!.friends!.map{ $0.key }
        friends.forEach { (friendUID) in
            UserActivity.observeUserActivity(userUID: friendUID) { (status) in
                
                let oldVal = self.statusOnlineFriends[friendUID]
                let newVal = status
                
                if oldVal == nil || oldVal! != newVal {
                    self.delegates.forEach { (delegate) in
                        delegate?.onlineStatusFriendChange(friend: friendUID, status: newVal)
                    }
                    self.statusOnlineFriends[friendUID] = status
                }
            }
        }
    }
    
    private func clear() {
        currentUser = nil
        friends = [:]
        groups = [:]
        friendsRequests = [:]
        listeners.forEach{ $0.remove() }
        listeners = []
    }
}

