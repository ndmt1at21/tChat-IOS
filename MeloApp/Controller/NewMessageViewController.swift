//
//  NewMessageViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController{

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableListFriends: UITableView!
    
    private var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.clipsToBounds = true
        
        let loading = LoadingIndicator(frame: view.bounds)
        loading.startAnimation()
        loading.isTurnBlurEffect = false
        tableListFriends.addSubview(loading)
    
        // Search View
        searchView.clipsToBounds = false
        searchView.shadow(0, 2, 2, UIColor.systemGray5.cgColor)
        
        // Table
        tableListFriends.delegate = self
        tableListFriends.dataSource = self
        tableListFriends.separatorStyle = .none
        
        tableListFriends.register(UINib(nibName: "ContactCell", bundle: .main), forCellReuseIdentifier: K.cellID.contactCell)
        
        guard let currentUser = Auth.auth().currentUser else {
            loading.stopAnimation()
            AuthController.shared.handleLogout()
            return
        }
        
        DatabaseController.getUser(userUID: currentUser.uid) { (user) in
            if let user = user {
                self.fetchDataFriends(currUser: user)
                loading.stopAnimation()
                loading.removeFromSuperview()
            }
            

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        tabBarController?.tabBar.isHidden = false
        print(isMovingFromParent)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disapp")
        print(navigationController?.viewControllers)
    }
    
    func fetchDataFriends(currUser: User) {

        guard let friends = currUser.friends else {
            return
        }
        
        friends.forEach { (friendUID) in
            DatabaseController.getUser(userUID: friendUID) { (friend) in
                if let friend = friend {
                    self.friends.append(friend)
                    self.tableListFriends.reloadData()
                }
            }
        }
    }
}

extension NewMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = friends[indexPath.row]
        
        print("to select")
        guard let currentUser = Auth.auth().currentUser else { return AuthController.shared.handleLogout()
        }
        
        print("cleicked")
        fetchGroup(from: [currentUser.uid, friend.uid!]) { (group) in
            guard let groupInfor = group else { return }

            print("slowwww")
            self.performSegue(withIdentifier: K.segueID.newMessageToChatLog, sender: groupInfor)
            print("comeback--newmessage???????")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueID.newMessageToChatLog {
            let group = sender as! Group
            let des = segue.destination as! ChatLogViewController
            des.group = group
        }
    }

    
    func fetchGroup(from usersUID: [StringUID], completion: @escaping (_ group: Group?) -> Void) {
        
        let groupRef = Firestore.firestore().collection("groups")
        
        let queryFindGroup = groupRef
            .whereField("members.\(usersUID[0])", isEqualTo: true)
            .whereField("members.\(usersUID[1])", isEqualTo: true)
        
        queryFindGroup.getDocuments { (snapshot, error) in
            
            if let docs = snapshot?.documents, docs.count > 0 {
                let doc = docs[0].data()
                
                let group = Group(
                    uid: docs[0].documentID,
                    createdAt: doc["createdAt"] as? UInt64,
                    createdBy: doc["createdBy"] as? StringUID,
                    members: doc["members"] as? [StringUID: Bool],
                    recentMessage: doc["recentMessage"] as? RecentMessage,
                    displayName: doc["displayName"] as? String
                )
                
                return completion(group)
            } else {
                // Create new group
                guard let currentUser = Auth.auth().currentUser else { return }
                var group = Group(
                    createdAt: Date().milisecondSince1970,
                    createdBy: currentUser.uid,
                    members: usersUID.reduce(into: [:], { (result, userUID) in
                        result[userUID] = true
                    }),
                    displayName: "Group"
                )
                
                do {
                    let ref = try groupRef.addDocument(from: group)
                    group.uid = ref.documentID
                    
                    return completion(group)
                } catch _ {
                    return completion(nil)
                }
                 
            }
        }
    }
}


extension NewMessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID.contactCell) as! ContactCell
        
        let friend = friends[indexPath.row]
        print(friend)
        cell.name.text = friend.name
        cell.imageCover = UIImageView()
        
        UserActivity.observeUserActivity(userUID: friend.uid!) { (isOnline) in
            cell.isOnline = isOnline
        }

        return cell
    }
    
    
}
