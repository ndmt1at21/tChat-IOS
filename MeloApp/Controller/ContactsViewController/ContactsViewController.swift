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

        CurrentUser.shared.addDelegate(delegate: self)
        setupNavBar()
        setupCollectionListFriends()
        getAllFriends()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
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
        
        setCurrentAvatarImage()
        
        customNavBar.firstRightButton.setImage(UIImage(systemName: "person.fill.badge.plus"), for: .normal)
        customNavBar.secondRightButton.setImage(UIImage(systemName: "person.crop.circle.badge.exclamationmark"), for: .normal)
    }
    
    private func setupCollectionListFriends() {
        collectionListFriends.delegate = self
        collectionListFriends.dataSource = self
    
        
        collectionListFriends.register(UINib(nibName: "ContactCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.contactCell)
        
        collectionListFriends.register(UINib(nibName: "HeaderContactCell", bundle: .main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: K.cellID.headerContactCell)
    }
    
    private func setupTransition() {
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
    }
    
    private func getAllFriends() {
        let friendsArr = CurrentUser.shared.friends.map { $0.value }
        
        let groupedFriends = Dictionary(grouping: friendsArr) { (friend) -> Character in
            return friend.name!.first!
        }
    
        self.friends = groupedFriends.map { $0.value }
        self.collectionListFriends.reloadData()
    }
    
    private func setCurrentAvatarImage() {
        if CurrentUser.shared.currentUser == nil { return }
        
        let imageLoading = ImageLoading()
        imageLoading.loadingImageAndCaching(
            target: self.customNavBar.userImage,
            with:  CurrentUser.shared.currentUser?.profileImageThumbnail,
            placeholder: nil,
            progressHandler: nil) { (error) in
            if (error != nil) { print(error!) }
        }
    }
}


// MARK: - CollectionDlelegate
extension ContactsViewController: UICollectionViewDelegate {

}

// MARK: - CollectionDataSource
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
 
        let headerView = collectionListFriends.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: K.cellID.headerContactCell, for: indexPath) as! HeaderContactCell
        
        if let name = friends[indexPath.section].first?.name {
            headerView.sectionTitle.text = String(name.first!).capitalized
        }
        
        return headerView
    }
}

// MARK: - CollectionFlowLayoutt
extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 20)
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

// MARK: - CurrentUserDelegate
extension ContactsViewController: CurrentUserDelegate {
    func onlineStatusFriendChange(friend: StringUID, status: Bool) {
        //
    }
    
    func incommingMessage(inGroup uid: StringUID, newMessage: Message) {
        //
    }
    
    func incommingFriendRequest(user: User) {
        //
    }
    
    func currentUserChange() {
        getAllFriends()
        setCurrentAvatarImage()
    }
}
