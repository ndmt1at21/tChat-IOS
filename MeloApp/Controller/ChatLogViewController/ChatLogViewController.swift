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
    
    @IBOutlet weak var customNavBar: NavigationBarChatLog!
    @IBOutlet weak var chatLogContentView: UIView!
    @IBOutlet weak var tableMessages: UITableView!

    @IBOutlet weak var chatTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var bottomConstraintChatLogContentView: NSLayoutConstraint!

    // just for track time
    var timer: Timer?
    
    var group: Group = Group()
    var messages: ListMessages = ListMessages()
    var members: [User] = []
    var onlineMembers: [StringUID: Bool] = [:]
    
    internal var isFirstFetchMessages: Bool = true
    internal var isLoadingMore: Bool = false
    internal var isEndLoadingMore: Bool = true
    internal var isEndMessages: Bool = false
    
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
        emotion.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return emotion
    }()
    
    lazy var toolbarEmotion: ToolbarEmotion = {
        let toolbar = ToolbarEmotion(frame: .zero)
        toolbar.backgroundColor = .white
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        return toolbar
    }()
    
    lazy var loadingIndicator: LoadingIndicator = {
        let loading = LoadingIndicator(frame: .zero)
        loading.isTurnBlurEffect = false
        loading.colorIndicator = .blue
        
        return loading
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCustomNavigationBar()
        setupTableMessages()
        setupObserverKeyboard()
        setupObserveTapScreen()
        setupChatTextView()
        setupInfoMembers()
        observerMembers()
        observerMessage(groupUID: group.uid!)
    }
    
    private func setupCustomNavigationBar() {
        
        customNavBar.backButton.backgroundColor = .white
        customNavBar.backButton.inkColor = .systemGray5
        
        customNavBar.infoButton.backgroundColor = .white
        customNavBar.infoButton.inkColor = .systemGray5
        
        group.getNameGroup { (name) in
            self.customNavBar.groupName.text = name
        }

        group.getGroupImageAvatar { (groupImage) in
            let imgLoading = ImageLoading()
            imgLoading.loadingImageAndCaching(
                target: self.customNavBar.groupImage,
                with: groupImage,
                placeholder: nil,
                progressHandler: nil) { (error) in
                if error != nil { print(error!) }
            }
        }
        
        customNavBar.delegate = self
        customNavBar.shadow(0, 2, 3, UIColor.systemGray5.cgColor)
    }
    
    private func setupObserveTapScreen() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapInScreen))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    private func setupInfoMembers() {
        if group.members == nil { return }
        
        let usersUID = group.members!.keys
        
        usersUID.forEach { (userUID) -> Void in
            DatabaseController.getUser(userUID: userUID) { (user) in
                if (user == nil) { return }
                
                self.members.append(user!)
            }
        }
    }
    
    private func observerMembers() {
        if group.members == nil { return }
        
        let usersUID = group.members!.keys
        usersUID.forEach { (userUID) -> Void in
            UserActivity.observeUserActivity(userUID: userUID) { (isOnline) in
                self.onlineMembers[userUID] = isOnline
                
                if self.onlineMembers.mapValues({$0}).count > 0 {
                    self.customNavBar.activityCircle.isHidden = false
                }
            }
        }
    }
    
    @objc func handleTapInScreen(_ sender: UITapGestureRecognizer) {
        chatTextView.endEditing(true)
        
        handleEmotionInputViewWillHide()
        
        toolbarEmotion.removeFromSuperview()
        tableMessages.isScrollEnabled = true
    }
    
    private func setupChatTextView() {
        chatTextView.textContainer.lineFragmentPadding = 1.25
        chatTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        chatTextView.layer.cornerRadius = 20
        chatTextView.delegate = self
        chatTextViewHeightConstraint.constant = chatTextView.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        PlayerManager.shared.clear()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabBarController?.tabBar.isHidden = true
        
        emotionInputView.frame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.height - EmotionInputView.kHeightEmotionInputView,
            width: UIScreen.main.bounds.width,
            height: EmotionInputView.kHeightEmotionInputView
        )
    }
  
    override func willMove(toParent parent: UIViewController?) {
        tabBarController?.tabBar.isHidden = true
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
        let text = chatTextView.text
        chatTextView.text = nil
        
        sendTextMessage(text: text) { (error) in
            if error != nil {
                print(error!)
                return
            }
            
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
}

// MARK: - PhotoPickerDelegate
extension ChatLogViewController: FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith assets: [PHAsset]) {
       
        tabBarController?.tabBar.isHidden = true
        
        guard let _ = Auth.auth().currentUser else { return }
        
        dismiss(animated: true, completion: nil)
        
        for asset in assets {
            self.sendImageAndVideoMessage(asset)
        }
    }
}

extension ChatLogViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let contentSize = chatTextView.contentSize
        self.chatTextViewHeightConstraint.constant = contentSize.height
        
        UserActivity.setCurrentUserTyping(true, groupID: group.uid!)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (_) in
            UserActivity.setCurrentUserTyping(false, groupID: self.group.uid!)
        })
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        chatTextView.tintColor = .black

        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UserActivity.setCurrentUserTyping(false, groupID: group.uid!)
    }
}

extension ChatLogViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
        if touch.view?.isDescendant(of: tableMessages) == true { return true }
        return false
    }
}

extension ChatLogViewController: NavigationBarChatLogDelegate {
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, backPressed sender: UIButton) {

        UIView.transition(with: self.navigationController!.view, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.navigationController?.popToRootViewController(animated: false)
        }, completion: nil)
    }
    
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, infoPressed sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.groupSettingViewController) as! GroupSettingViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, groupInfoViewPressed sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(identifier: K.sbID.groupSettingViewController) as! GroupSettingViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
