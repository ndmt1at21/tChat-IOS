//
//  ChatLogViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/19/20.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

class ChatLogViewController: UIViewController {

    @IBOutlet weak var imageCover: UIImageView!
    
    @IBOutlet weak var chatLogContentView: UIView!
    @IBOutlet weak var tableMessages: UITableView!

    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var bottomConstraintChatLogContentView: NSLayoutConstraint!

    
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var groupStatus: UILabel!
    
    var group: Group = Group()
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableMessages.delegate = self
        tableMessages.dataSource = self
        
        tableMessages.register(UINib(nibName: "BubbleChatFromMe", bundle: .main), forCellReuseIdentifier: K.cellID.bubbleChatFromMe)
        tableMessages.register(UINib(nibName: "BubbleChatFromFriend", bundle: .main), forCellReuseIdentifier: K.cellID.bubbleChatFromFriend)
        
        
        tableMessages.estimatedRowHeight = 100
        tableMessages.rowHeight = UITableView.automaticDimension
        
        setupScreenInfor()
        setupObserveKeyboard()
        setupImageCover()

        observeMessage(groupUID: group.uid!)
    }
    
    func setupScreenInfor() {
        nameGroup.text = group.displayName
    }
    
    func setupImageCover() {
        imageCover.layer.cornerRadius = imageCover.layer.frame.height / 2
    }
    
    func setupObserveKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationItem.hidesBackButton = false
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        
        let window = UIApplication.shared.windows[0]
        let bottomPadding = window.safeAreaInsets.bottom
        bottomConstraintChatLogContentView.constant = keyboardFrame!.height - bottomPadding
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
            
            if self.messages.count > 0 {
                self.tableMessages.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        bottomConstraintChatLogContentView.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        handleSendMessage()
    }
    
    func handleSendMessage() {
        guard var message = chatTextView.text else { return }
        
        message = message.trimmingCharacters(in: ["\n", " "])
        if message.count == 0 { return }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Firestore.firestore().collection("messages").document(group.uid!).collection("messages").document().setData([
            "sendBy": currentUser.uid,
            "sendAt": Date().milisecondSince1970,
            "type": TypeMessage.text.rawValue,
            "content": message
        ])
        
        chatTextView.text = nil
    }
    
    private func observeMessage(groupUID: StringUID) {
        let groupRef = Firestore.firestore().collection("messages").document(groupUID).collection("messages").order(by: "sendAt").limit(toLast: 10)
        
        groupRef.addSnapshotListener { (querySnapshot, error) in
            guard let docsChange = querySnapshot?.documentChanges else { return }
            
            docsChange.forEach { (doc) in
                
                let data = doc.document.data()
                
                if doc.type == .added {
                    let message = Message(
                        uid: doc.document.documentID,
                        sendBy: data["sendBy"] as! StringUID,
                        sendAt: data["sendAt"] as? UInt64,
                        type: data["type"] as? TypeMessage,
                        content: data["content"] as? String
                    )
                    self.messages.append(message)
                    
                } else if doc.type == .removed {
                    
                }
            }
            
           
            DispatchQueue.main.async {
                self.tableMessages.reloadData()
                
                if self.messages.count > 0 {
                    self.tableMessages.scrollToRow(
                        at: IndexPath(
                            row: self.messages.count - 1,
                            section: 0),
                        at: .bottom, animated: true
                    )
                }
            }
        }
    }
    
}


extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatLogViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]

        let cell = setupMessageCell(tableView, for: message)
        
        return cell
    }
    
    private func setupMessageCell(_ tableView: UITableView, for message: Message) -> UITableViewCell {
        guard let currentUser = Auth.auth().currentUser else {
            AuthController.handleLogout()
            return UITableViewCell()
        }
        
        if message.sendBy == currentUser.uid {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: K.cellID.bubbleChatFromMe
            ) as! BubbleChatFromMe
            
            cell.message.text = message.content
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: K.cellID.bubbleChatFromFriend
            ) as! BubbleChatFromFriend
            
            cell.message.text = message.content
            return cell
        }
    }
    
    
    
}
