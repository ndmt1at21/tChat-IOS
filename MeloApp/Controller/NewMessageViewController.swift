//
//  NewMessageViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/18/20.
//

import UIKit
import Firebase
import MaterialComponents

class NewMessageViewController: UIViewController{

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionListFriends: UICollectionView!
    @IBOutlet weak var customNavBar: NavigationBarNormal!
    
    lazy var loading: LoadingIndicator = {
        let loading = LoadingIndicator(frame: view.bounds)
        loading.startAnimation()
        loading.isTurnBlurEffect = false
        
        return loading
    }()
    
    private var friends: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        setupLoadingView()
        setupSearchView()
        setupCollectionListFriends()
        fetchFriendsAndUpdateTable()
    }
    
    private func setupCustomNavBar() {
        customNavBar.delegate = self
        
        customNavBar.titleLabel.text = "Tin nhắn mới"
        customNavBar.preferLarge = false
        
        customNavBar.backgroundColor = .white
        customNavBar.backButton.backgroundColor = .white
        customNavBar.backButton.inkColor = .systemGray5
    }
    
    private func setupLoadingView() {
        loading.frame = view.bounds
        collectionListFriends.addSubview(loading)
    }
    
    private func setupSearchView() {
        searchView.clipsToBounds = false
        searchView.shadow(0, 2, 2, UIColor.systemGray5.cgColor)
    }
    
    private func setupCollectionListFriends() {
        collectionListFriends.delegate = self
        collectionListFriends.dataSource = self
        collectionListFriends.register(UINib(nibName: "ContactCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.contactCell)
    }
    
    private func fetchFriendsAndUpdateTable() {
        guard let currentUser = Auth.auth().currentUser else {
            loading.stopAnimation()
            AuthController.shared.handleLogout()
            return
        }
        
        DatabaseController.getUser(userUID: currentUser.uid) { (user) in
            if let user = user {
                self.fetchDataFriends(currUser: user)
                self.loading.stopAnimation()
                self.loading.removeFromSuperview()
            }
        }
    }
    
    private func fetchDataFriends(currUser: User) {

        guard let friends = currUser.friends?.keys else {
            return
        }
        
        friends.forEach { (friendUID) in
            DatabaseController.getUser(userUID: friendUID) { (friend) in
                if let friend = friend {
                    self.friends.append(friend)
                    self.collectionListFriends.reloadData()
                }
            }
        }
    }
    
    private func fetchGroup(from usersUID: [StringUID], completion: @escaping (_ group: Group?) -> Void) {
        
        let groupRef = Firestore.firestore().collection("groups")
        
        let queryFindGroup = groupRef
            .whereField("members.\(usersUID[0])", isEqualTo: true)
            .whereField("members.\(usersUID[1])", isEqualTo: true)
        
        queryFindGroup.getDocuments { (snapshot, error) in
            
            if let docs = snapshot?.documents, docs.count > 0 {
                
                let doc = docs[0].data()
                let group = Group(uid: docs[0].documentID, dataFromServer: doc)
                
                return completion(group)
            } else {
                // Create new group
                guard let currentUser = Auth.auth().currentUser else { return }
                
                var group = Group(
                    createdBy: currentUser.uid,
                    members: usersUID.reduce(into: [:], { (result, userUID) in
                        result[userUID] = true
                    }),
                    recentMessage: nil,
                    displayName: "GroupTest"
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueID.newMessageToChatLog {
            let group = sender as! Group
            let des = segue.destination as! ChatLogViewController
            des.group = group
        }
    }
}

extension NewMessageViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let friend = friends[indexPath.row]
        
        guard let currentUser = Auth.auth().currentUser else {
            return AuthController.shared.handleLogout()
        }
        
        fetchGroup(from: [currentUser.uid, friend.uid!]) { (group) in
            guard let groupInfor = group else { return }

            self.performSegue(withIdentifier: K.segueID.newMessageToChatLog, sender: groupInfor)
        }
    }
}

extension NewMessageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionListFriends.dequeueReusableCell(withReuseIdentifier: K.cellID.contactCell, for: indexPath) as! ContactCell
        
 
        let friend = friends[indexPath.row]
 
        cell.userModel = friend
        UserActivity.observeUserActivity(userUID: friend.uid!) { (isOnline) in
            cell.isOnline = isOnline
        }

        return cell
    }
}

extension NewMessageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension NewMessageViewController: NavigationBarNormalDelegate {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton) {
        
        navigationController?.hero.isEnabled = true
        navigationController?.popViewController(animated: true)
    }
}
