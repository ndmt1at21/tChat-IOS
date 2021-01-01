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
    
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableConversation.delegate = self
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
