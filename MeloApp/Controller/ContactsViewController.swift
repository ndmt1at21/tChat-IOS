//
//  ContactsViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableContact: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(handleFriendRequest))
    }
    
    @objc func handleFriendRequest() {
        
    }

}
