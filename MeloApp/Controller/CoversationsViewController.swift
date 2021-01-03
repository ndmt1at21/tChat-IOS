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
    
    private func setupCustomNavBar() {
        let config = UIImage.SymbolConfiguration(pointSize: 12.0, weight: .heavy, scale: .large)
        
        customNavigationBar.titleLabel.text = "Chats"
        customNavigationBar.secondRightButton.isHidden = true
        customNavigationBar.userImage.image = UIImage(named: "john")
        
        let imagePen = UIImage(systemName: "pencil", withConfiguration: config)
        customNavigationBar.firstRightButton.setImage(imagePen, for: .normal)
        
        customNavigationBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {

        UserActivity.updateCurrentUserActivity(false)
        AuthController.shared.handleLogout()
        
        performSegue(withIdentifier: "UnwindToLoginController", sender: self)
    }
    
    
    @IBAction func newMessagePressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ConversationToNewMessage", sender: self)
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
        //
    }
}
