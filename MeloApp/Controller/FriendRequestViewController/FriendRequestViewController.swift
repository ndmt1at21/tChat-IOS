//
//  FriendRequestViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 1/6/21.
//

import UIKit
import Firebase

class FriendRequestViewController: UIViewController {

    @IBOutlet weak var customNavBar: NavigationBarNormal!
    var friendRequests: [User] = []
    @IBOutlet weak var tableFriendRequest: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupTableFriendRequests()
        fetchAllFriendRequests()
    }
    
    private func setupNavBar() {
        customNavBar.titleLabel.text = "Lời mời kết bạn"
        customNavBar.preferLarge = false
        customNavBar.delegate = self
    }
    
    
    private func setupTableFriendRequests() {
        tableFriendRequest.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableFriendRequest.delegate = self
        tableFriendRequest.dataSource = self
        
        let nib = UINib(nibName: "FriendRequestCell", bundle: .main)
        tableFriendRequest.register(nib, forCellReuseIdentifier: K.cellID.friendRequestCell)
    }

    private func fetchAllFriendRequests() {
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        
        // fetch friend requets detail
        guard let requestsID = currentUser.friendRequests?.keys else  { return }
        
        requestsID.forEach { (userUID) in
            DatabaseController.getUser(userUID: userUID) { (user) in
                if user == nil {
                    return
                }
                
                self.friendRequests.append(user!)
                self.tableFriendRequest.reloadData()
            }
        }
    }
}

// MARK: - TableDelegate
extension FriendRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension FriendRequestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableFriendRequest.dequeueReusableCell(withIdentifier: K.cellID.friendRequestCell) as! FriendRequestCell
        
        cell.userModel = friendRequests[indexPath.item]
        cell.delegate = self
        
        return cell
    }
}

// MARK: - FriendCellDelegate
extension FriendRequestViewController: FriendRequestCellDelegate {
    func acceptDidPressed(_ cell: FriendRequestCell, userUID: StringUID) {
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        
        let ref =  Firestore.firestore().collection("users").document(currentUser.uid!)
        
        // add friend to friend field of current user
        ref.updateData(["friends.\(userUID)": true])
        
        // delete request from data base
        ref.updateData(["friendRequests.\(userUID)": FieldValue.delete()])
    }
    
    func deleteDidPressed(_ cell: FriendRequestCell, userUID: StringUID) {
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        Firestore.firestore().collection("users").document(currentUser.uid!).updateData(["friendRequests.\(userUID)": FieldValue.delete()])
    }
}

// MARK: - CustomNavigationBarDelegate
extension FriendRequestViewController: NavigationBarNormalDelegate {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton) {
        
        navigationController?.hero.isEnabled = true
        navigationController?.popViewController(animated: true)
    }
}
