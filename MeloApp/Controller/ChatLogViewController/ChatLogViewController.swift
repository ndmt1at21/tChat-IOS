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
import ISEmojiView

class ChatLogViewController: UIViewController {

    @IBOutlet weak var imageCover: UIImageView!
    
    @IBOutlet weak var chatLogContentView: UIView!
    @IBOutlet weak var tableMessages: UITableView!

    @IBOutlet weak var chatTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var nameGroup: UILabel!
    @IBOutlet weak var groupStatus: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var bottomConstraintChatLogContentView: NSLayoutConstraint!
    
    var group: Group = Group()
    var messages: [Message] = []
    var nMessagePending: Int = 0
    
    internal var isKeyboardShow: Bool = false
    internal var isEmotionInputShow: Bool = false {
        didSet {
            emotionInputView.isHidden = !isEmotionInputShow
        }
    }
    
    internal lazy var videoDetailViewController: VideoDetailViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let instance = storyboard.instantiateViewController(identifier: K.sbID.videoDetailViewController) as! VideoDetailViewController
        
        return instance
    }()
    
    lazy var emotionInputView: EmotionInputView = {
        let emotion = EmotionInputView(frame: .zero)
        emotion.delegate = self
        emotion.isHidden = true
        return emotion
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupTableMessages()
        setupScreenInfor()
        setupObserverKeyboard()
        setupObserveTapScreen()
        setupImageCover()
        setupChatTextView()
        observerMessage(groupUID: group.uid!)
    }

    private func setupObserveTapScreen() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapInScreen))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    @objc func handleTapInScreen(_ sender: UITapGestureRecognizer) {
        chatTextView.endEditing(true)
        handleEmotionInputViewWillHide()
    }
    
    private func setupChatTextView() {
        chatTextView.textContainer.lineFragmentPadding = 1.25
        chatTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        chatTextView.layer.cornerRadius = 20
        chatTextView.delegate = self
        chatTextViewHeightConstraint.constant = chatTextView.contentSize.height
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
        PlayerManager.shared.clear()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableMessages.layoutIfNeeded()
        tabBarController?.tabBar.isHidden = true
    }
  
    override func willMove(toParent parent: UIViewController?) {
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
        IQKeyboardManager.shared.enable = true
    }
    

    @IBAction func emojiButtonPressed(_ sender: UIButton) {
        if emotionInputView.isHidden {
            handleEmotionInputViewWillShow()
            chatTextView.resignFirstResponder()
        } else {
            chatTextView.becomeFirstResponder()
            handleEmotionInputViewWillHide()
        }
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendTextMessage { (error) in
            if error != nil {
                print(error!)
                return
            }
            
            self.chatTextView.text = nil
            self.chatTextViewHeightConstraint.constant = self.chatTextView.contentSize.height
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
                            self.scrollToBottom(animation: true)
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
       
        tabBarController?.tabBar.isHidden = true
        
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
                if error != nil { print(error!) }
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
                self.scrollToBottom(animation: true)
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

extension ChatLogViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let contentSize = chatTextView.contentSize
        self.chatTextViewHeightConstraint.constant = contentSize.height
        self.view.layoutIfNeeded()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        chatTextView.tintColor = .black
        chatTextView.keyboardType = .default
        return true
    }
}

extension ChatLogViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
        if touch.view?.isDescendant(of: tableMessages) == true { return true }
        return false
    }
}
