//
//  CoversationsViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit
import Firebase

class CoversationsViewController: UIViewController {


    @IBOutlet weak var collectionConversations: UICollectionView!
    @IBOutlet weak var customNavigationBar: NavigationBarMain!
    
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.shared.addDelegate(delegate: self)
        setupCustomNavBar()
        setupCollectionConversation()
        fetchDataGroup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionConversations.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hero.isEnabled = false
    }
    
    private func setupCustomNavBar() {
        let config = UIImage.SymbolConfiguration(pointSize: 12.0, weight: .heavy, scale: .large)
        
        customNavigationBar.titleLabel.text = "Chats"
        customNavigationBar.secondRightButton.isHidden = true
            
        setCurrentAvatarImage()
        
        let imagePen = UIImage(systemName: "pencil", withConfiguration: config)
        customNavigationBar.firstRightButton.setImage(imagePen, for: .normal)
        customNavigationBar.delegate = self
    }
    
    private func setupCollectionConversation() {
        collectionConversations.delegate = self
        collectionConversations.dataSource = self
        collectionConversations.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionConversations.register(UINib(nibName: "ConversationPrivateCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.conversationPrivate)
    }
    
    private func setupTransition() {
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
    }
    
    private func fetchDataGroup() {
        
        guard let currentUser = CurrentUser.shared.currentUser else { return }
        
        Firestore.firestore().collection("groups")
            .whereField("members.\(currentUser.uid!)", isEqualTo: true).getDocuments { (querySnap, error) in
                if (error != nil) {
                    print(error!.localizedDescription)
                }
                
                querySnap?.documents.forEach({ (queryDocSnap) in
                    let data = queryDocSnap.data()
                    
                    let group = Group(uid: queryDocSnap.documentID, dataFromServer: data)

                    self.groups.append(group)
                    self.collectionConversations.reloadData()
                })
            }
        
        collectionConversations.reloadData()
    }
    
    @IBAction func newMessagePressed(_ sender: UIBarButtonItem) {
   
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.coversationsViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setCurrentAvatarImage() {
        if CurrentUser.shared.currentUser == nil { return }
        
        let imageLoading = ImageLoading()
        imageLoading.loadingImageAndCaching(
            target: self.customNavigationBar.userImage,
            with:  CurrentUser.shared.currentUser?.profileImageThumbnail,
            placeholder: nil,
            progressHandler: nil) { (error) in
            if (error != nil) { print(error!) }
        }
    }
}

extension CoversationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.chatLogViewController) as! ChatLogViewController
       
        vc.group = groups[indexPath.item]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CoversationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionConversations.dequeueReusableCell(withReuseIdentifier: K.cellID.conversationPrivate, for: indexPath) as! ConversationPrivateCell
        
        cell.groupModel = groups[indexPath.item]
        
        return cell
    }
}

extension CoversationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 60)
    }
}

extension CoversationsViewController: NavigationBarMainDelegate {
    func navigationBar(_ naviagtionBarMain: NavigationBarMain, firstRightPressed sender: UIButton) {
  
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.newMessageViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationBar(_ naviagtionBarMain: NavigationBarMain, userImagePressed sender: UITapGestureRecognizer) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.userSettingViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CoversationsViewController: CurrentUserDelegate {
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
        setCurrentAvatarImage()
    }
}
