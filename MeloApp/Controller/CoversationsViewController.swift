//
//  CoversationsViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class CoversationsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionFriendOnline: UICollectionView!
    @IBOutlet weak var tableConversation: UITableView!
    @IBOutlet weak var customNavigationBar: NavigationBarMain!
    
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableConversation.delegate = self
        setupCustomNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hero.isEnabled = false
    }
    
    private func setupCustomNavBar() {
        let config = UIImage.SymbolConfiguration(pointSize: 12.0, weight: .heavy, scale: .large)
        
        customNavigationBar.titleLabel.text = "Chats"
        customNavigationBar.secondRightButton.isHidden = true
        
        // loading user image
        AuthController.shared.listenChangeCurrentUser { (user) in
            if user == nil { return }
            
            let imageLoading = ImageLoading()
            imageLoading.loadingImageAndCaching(
                target: self.customNavigationBar.userImage,
                with: AuthController.shared.currentUser?.profileImageThumbnail,
                placeholder: nil,
                progressHandler: nil) { (error) in
                if (error != nil) { print(error!) }
            }
        }
        
        let imagePen = UIImage(systemName: "pencil", withConfiguration: config)
        customNavigationBar.firstRightButton.setImage(imagePen, for: .normal)
        customNavigationBar.delegate = self
    }
    
    private func setupTransition() {
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
    }
    
    @IBAction func newMessagePressed(_ sender: UIBarButtonItem) {
   
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.coversationsViewController)
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CoversationsViewController: UITableViewDelegate {
    
}

extension CoversationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
