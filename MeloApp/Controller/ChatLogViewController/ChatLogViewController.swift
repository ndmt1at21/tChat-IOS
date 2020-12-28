//
//  ChatLogViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/19/20.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FMPhotoPicker
import Photos
import Kingfisher

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
    var nMessagePending: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableMessages()
        setupScreenInfor()
        setupObserverKeyboard()
        setupImageCover()

        self.hero.isEnabled = true
        observerMessage(groupUID: group.uid!)
    }
    
    func setupTableMessages() {
        tableMessages.delegate = self
        tableMessages.dataSource = self
        tableMessages.prefetchDataSource = self
        tableMessages.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tableMessages.register(UINib(nibName: K.nib.bubbleTextChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleTextChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleImageChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleImageChat)
        tableMessages.register(UINib(nibName: K.nib.bubbleVideoChat, bundle: .main), forCellReuseIdentifier: K.cellID.bubbleVideoChat)
        
        tableMessages.estimatedRowHeight = 100
        tableMessages.rowHeight = UITableView.automaticDimension
    }
    
    func setupScreenInfor() {
        nameGroup.text = group.displayName
    }
    
    func setupImageCover() {
        imageCover.layer.cornerRadius = imageCover.layer.frame.height / 2
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableMessages.layoutIfNeeded()
    }
  
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendTextMessage { (error) in

        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        var config = FMPhotoPickerConfig()
        config.mediaTypes = [.image, .video]
        config.selectMode = .multiple
        config.maxImage = 10
        config.maxVideo = 10
        config.shouldReturnAsset = true
        
        let imagePicker = FMPhotoPickerViewController(config: config)
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func observerMessage(groupUID: StringUID) {
        let groupRef = Firestore.firestore().collection("messages").document(groupUID).collection("messages").order(by: "sendAt").limit(toLast: 10)
        
        groupRef.addSnapshotListener { (querySnapshot, error) in
            guard let docsChange = querySnapshot?.documentChanges else {
                return
            }
            
            docsChange.forEach { (doc) in
                let data = doc.document.data()
 
                if doc.type == .added {
                    let message = Message(uid: doc.document.documentID, dictionary: data)
                    
                    let position = self.messages.lastIndex {
                        $0.idLocalPending != nil && self.nMessagePending != 0
                            && $0.idLocalPending == message.idLocalPending && $0.uid == nil
                    }
                    
                    if let pos = position {
                        self.nMessagePending -= 1
                        self.messages[pos] = message
                    } else {
                        self.messages.append(message)
                                            
                        DispatchQueue.main.async {
                            self.tableMessages.reloadData()
                            self.scrollToBottom()
                        }
                    }
                } else if doc.type == .removed {
                    
                }
            }
        }
    }
}

// MARK: - PhotoPickerDelegate
extension ChatLogViewController: FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith assets: [PHAsset]) {

        guard let _ = Auth.auth().currentUser else { return }
        
        dismiss(animated: true, completion: nil)
        
        for asset in assets {
            let uidLocalPending = UUID().uuidString
            
            // handle show image, video immedietly when pressed send
            sendLocalMessage(asset, uidLocalPending) { (error) in
                print("send local success")
                if error != nil { return }
                
                // upload to firestore and send message to firebase
                self.sendImageAndVideoMessage(asset, uidLocalPending)
            }
        }
    }
}

// MARK: - TableViewDelegate
extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let type = messages[indexPath.row].type {
            return type.bubbleHeight(messages[indexPath.row])
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
 
        return UITableView.automaticDimension
    }
}


// MARK: - TableViewDataSource
extension ChatLogViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let type: TypeMessage = messages[indexPath.row].type!

        return type.bubbleChatCell(tableView, message: message, self)
    }
}

extension ChatLogViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        let imageThumnailUrls = messages
//            .filter{ $0.thumbnail != nil
//                && $0.type == TypeMessage.image
//                || $0.type == TypeMessage.video
//            }.map{ URL(string: $0.thumbnail!)! }
//
//        ImagePrefetcher(urls: imageThumnailUrls).start()
    }
}

// MARK: - HandleSendMessage
extension ChatLogViewController {
    func sendTextMessage(completion: @escaping (_ error: String?) -> Void) {
        guard var text = chatTextView.text else { return }
        
        text = text.trimmingCharacters(in: ["\n", " "])
        if text.count == 0 { return }
        
        guard let currentUser = Auth.auth().currentUser else { return }
        let message = Message(
            currentUser.uid,
            Date().milisecondSince1970,
            TypeMessage.text,
            text
        )
        
        chatTextView.text = nil
        sendMessageFirestore(message: message, to: group.uid!) { (error) in
            if error != nil {
                return completion(nil)
            }
            
            return completion(error)
        }
    }
    
    func sendImageAndVideoMessage(_ asset: PHAsset, _ localUID: StringUID) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let imageAsset = asset.getImage()
        var urlOrigin: URL?
        var urlThumbnail: URL?
        var type: TypeMessage = .image
        let currIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
        
        switch asset.mediaType {
        case .image: type = .image
        case .video: type = .video
        default: return
        }
        
        var message = Message(
            currentUser.uid,
            Date().milisecondSince1970,
            type, nil
        )
        
        let dispatchGroup = DispatchGroup()
        
        // upload original source
        dispatchGroup.enter()
        if type == .image {
    
            StorageController.uploadImage(imageAsset) { (snapshot) in
                if let imgCell = self.tableMessages.cellForRow(
                    at: currIndexPath) as? BubbleImageChat {
                    
                    DispatchQueue.main.async {
                        imgCell.progressBar.isHidden = false
                        imgCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
                    }
                }

                snapshot.reference.downloadURL { (urlImage, error) in

                    if error != nil {
                        print("Error: ", error!.localizedDescription)
                        return
                    }
                    urlOrigin = urlImage
                    dispatchGroup.leave()
                }
            }
        } else if type == .video {
            StorageController.uploadVideo(asset) { (snapshot) in
                if let videoCell = self.tableMessages.cellForRow(
                    at: currIndexPath) as? BubbleVideoChat {
  
                    DispatchQueue.main.async {
                        videoCell.progressBar.isHidden = false
                        videoCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
                    }
                }
                
                snapshot.reference.downloadURL { (urlVideo, error) in
                    
                    if error != nil {
                        print("Error: ", error!.localizedDescription)
                        return
                    }
                    urlOrigin = urlVideo
                    dispatchGroup.leave()
                }
            }
        }
        
        // upload thumbnail image
        dispatchGroup.enter()
        guard let thumbnail = imageAsset.resize(width: 200) else {
            return
        }
        
        StorageController.uploadImage(thumbnail) { (snapshot) in
            snapshot.reference.downloadURL { (urlThumb, error) in
                if error != nil {
                    print("Error: ", error!.localizedDescription)
                    return
                }
                urlThumbnail = urlThumb
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let cell = self.tableMessages.cellForRow(at: currIndexPath) as! BubbleBaseChat
            cell.progressBar.isHidden = true
            
            message.type = type
            message.content = urlOrigin?.absoluteString
            message.thumbnail = urlThumbnail?.absoluteString
            message.imageWidth = UInt64(thumbnail.size.width)
            message.imageHeight = UInt64(thumbnail.size.height)
            message.idLocalPending = localUID
            
            self.sendMessageFirestore(message: message, to: self.group.uid!) { (error) in
                print(error)
            }
        }
    }
    

    func sendLocalMessage(_ asset: PHAsset, _ localUID: StringUID, completion: @escaping (_ error: String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        var message = Message(
            currentUser.uid,
            Date().milisecondSince1970,
            nil, nil
        )
        
        // add to message local
        asset.getURL { (url) in
            guard let urlStr = url?.absoluteString else { return }
            let imageThumb = asset.getImage()
       
            switch asset.mediaType {
            case .image: message.type = .image
            case .video: message.type = .video
            default: return completion("Error type")
            }
            
            message.content = urlStr
            message.imageWidth = UInt64(imageThumb.size.width)
            message.imageHeight = UInt64(imageThumb.size.height)
            message.idLocalPending = localUID
           
            self.nMessagePending += 1
            self.messages.append(message)
                    
            DispatchQueue.main.async {
                self.tableMessages.reloadData()
                self.scrollToBottom()
            }
            
            return completion(nil)
        }
    }

    func sendMessageFirestore(message: Message, to groupUID: StringUID, completion: @escaping (_ error: String?) -> Void) {
        guard let _ = Auth.auth().currentUser else { return }
        
        do {
            try Firestore.firestore().collection("messages").document(groupUID).collection("messages").document().setData(from: message)
            return completion(nil)
        } catch let error {
            return completion(error.localizedDescription)
        }
    }
}
