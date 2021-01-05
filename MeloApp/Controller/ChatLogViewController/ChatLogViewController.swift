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
    
    @IBOutlet weak var chatLogContentView: UIView!
    @IBOutlet weak var tableMessages: UITableView!

    @IBOutlet weak var chatTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var bottomConstraintChatLogContentView: NSLayoutConstraint!
    
    var group: Group = Group()
    var messages: ListMessage = ListMessage()
    
    @IBOutlet weak var customNavBar: NavigationBarChatLog!
    
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
        observerMessage(groupUID: group.uid!)
    }

    private func setupCustomNavigationBar() {
        customNavBar.delegate = self

        customNavBar.backButton.backgroundColor = .white
        customNavBar.backButton.inkColor = .systemGray5
        
        customNavBar.infoButton.backgroundColor = .white
        customNavBar.infoButton.inkColor = .systemGray5
        
        customNavBar.shadow(0, 2, 3, UIColor.systemGray5.cgColor)
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
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        IQKeyboardManager.shared.enable = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        PlayerManager.shared.clear()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableMessages.layoutIfNeeded()
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

extension ChatLogViewController: NavigationBarChatLogDelegate {
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, backPressed sender: UIButton) {

        UIView.transition(with: self.navigationController!.view, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.navigationController?.popToRootViewController(animated: false)
        }, completion: nil)
    }
    
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, infoPressed sender: UIButton) {
        //
    }
    
    func navigationBar(_ naviagtionBarChatLog: NavigationBarChatLog, groupInfoViewPressed sender: UITapGestureRecognizer) {
        //
    }
}
