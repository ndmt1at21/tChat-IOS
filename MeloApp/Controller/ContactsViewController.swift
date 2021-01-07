//
//  ContactsViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit
import Firebase

class ContactsViewController: UIViewController {

 
    @IBOutlet weak var customNavBar: NavigationBarMain!
    @IBOutlet weak var collectionListFriends: UICollectionView!
    
    var friends: [[User]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupCollectionListFriends()
        fetchAllFriends()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionListFriends.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hero.isEnabled = false
    }
    
    private func setupNavBar() {
        customNavBar.delegate = self
        customNavBar.titleLabel.text = "Danh bạ"
        
        customNavBar.firstRightButton.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        customNavBar.secondRightButton.setImage(UIImage(systemName: "person.crop.circle.badge.exclamationmark"), for: .normal)
    }
    
    private func setupCollectionListFriends() {
        collectionListFriends.delegate = self
        collectionListFriends.dataSource = self
        collectionListFriends.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let nib = UINib(nibName: "ContactCell", bundle: .main)
        collectionListFriends.register(nib, forCellWithReuseIdentifier: K.cellID.contactCell)
    }
    
    private func fetchAllFriends() {
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        
        guard let allFriendsUID = currentUser.friends?.keys else { return }
        
        var allFriends: [User] = []
            
        allFriendsUID.forEach { (userUID) in
            DatabaseController.getUser(userUID: userUID) { (user) in
                if user == nil {
                    return
                }
                
                allFriends.append(user!)
                
                let groupedFriends = Dictionary(grouping: allFriends) { (friend) -> Character in
                    return friend.name!.first!
                }
            
                
                self.friends = groupedFriends.map { $0.value }
                
                self.collectionListFriends.reloadData()
            }
        }
    }
    
    private func setupTransition() {
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
    }
}


// MARK: - CollectionDlelegate
extension ContactsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }

}

extension ContactsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionListFriends.dequeueReusableCell(withReuseIdentifier: K.cellID.contactCell, for: indexPath) as! ContactCell
        
        cell.userModel = friends[indexPath.section][indexPath.item]
        return cell
    }
    
    
}

extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


// MARK: - CustomNavBar
extension ContactsViewController: NavigationBarMainDelegate {
    func navigationBar(_ naviagtionBarMain: NavigationBarMain, firstRightPressed sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.addFriendViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationBar(_ naviagtionBarMain: NavigationBarMain, secondRightPressed sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.friendRequestViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationBar(_ naviagtionBarMain: NavigationBarMain, userImagePressed sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let vc = storyboard.instantiateViewController(identifier: K.sbID.userSettingViewController)
        navigationController?.pushViewController(vc, animated: true)
    }
}

