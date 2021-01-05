//
//  ChatLogViewController+Networking.swift
//  MeloApp
//
//  Created by Minh Tri on 1/2/21.
//

import UIKit
import Photos
import Firebase

extension ChatLogViewController {
    internal func observerMessage(groupUID: StringUID) {
        
        let db = Firestore.firestore()
        
        let groupRef = db.collection("messages").document(groupUID).collection("messages").order(by: "sendAt").limit(toLast: 10)
    
        groupRef.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
            guard let docsChange = querySnapshot?.documentChanges else {
                return
            }
     
            var addedMessages: [Message] = []
            
            docsChange.forEach { (doc) in
                let data = doc.document.data()

                var message = Message(uid: doc.document.documentID, dataFromServer: data)
                
                if message.sendAt == nil && querySnapshot!.metadata.hasPendingWrites {
                    message.sendAt = Timestamp().dateValue()
                }
                  
                switch doc.type {
                case .added:
                    addedMessages.append(message)
                case .modified:
                    self.messages.updateMessage(message)
                case .removed:
                    print("ccccccc")
                }
            }
            
            // group message
            self.messages.addSectionLast(addedMessages)
            self.scrollToBottom(animation: true)
        }
    }
    
    internal func sendTextMessage(text: String?, completion: @escaping (_ error: String?) -> Void) {
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        
        guard let safeText = text else { return }
        let textMessage = safeText.trimmingCharacters(in: ["\n", " "])
        
        if textMessage.count == 0 { return }

        let message = Message(currentUser.uid!, .text, textMessage)

        DatabaseController.sendMessage(message: message, to: group.uid!) { (docID, error) in
            if error != nil {
                return completion(error)
            }
            return completion(nil)
        }
    }
    
    internal func sendImageAndVideoMessage(_ asset: PHAsset) {
        guard let currentUser = AuthController.shared.currentUser else { return }

        var type: TypeMessage = .image
        let imageAsset = asset.getImage()
        var currIndexPath = IndexPath(
            row: -1,
            section: -1
        )
        
        switch asset.mediaType {
        case .image: type = .image
        case .video: type = .video
        default:
            print("Error: Asset type not support")
            return
        }
        
        var message = Message(
            currentUser.uid,
            type, nil, nil,
            UInt64(imageAsset.size.width),
            UInt64(imageAsset.size.height)
        )
    
        // First, send message with original url
        // For show image and video immediately
        var messageUID: StringUID?
        
        asset.getURL { (url) in
            guard let localUrl = url else { return }
            message.content = localUrl.absoluteString
            
            DatabaseController.sendMessage(message: message, to: self.group.uid!) { (docUID, error) in
                if error != nil {
                    print("Error:", error!)
                    return
                }
                
                messageUID = docUID
                currIndexPath.section = self.messages.count - 1
                currIndexPath.row = self.messages[self.messages.count - 1].count - 1

                self.uploadOriginalSourceAndThumbnail(asset, imageAsset, updateProgressCellAt: currIndexPath, messageWillUpdateAt: messageUID)
            }
        }
       
 
    }
    
    internal func sendStickerMessage(_ url: String?, completion: @escaping (_ error: String?) -> Void) {
        guard let currentUser = AuthController.shared.currentUser else { return }
        
        guard let safeUrl = url else { return }
        
        let message = Message(currentUser.uid, .sticker, safeUrl)

        DatabaseController.sendMessage(message: message, to: group.uid!) { (docID, error) in
            if error != nil {
                return completion(error)
            }
            return completion(nil)
        }
    }
    
    private func uploadOriginalSourceAndThumbnail(_ asset: PHAsset, _ imageAsset: UIImage, updateProgressCellAt indexPath: IndexPath, messageWillUpdateAt uid: StringUID?) {
        
        let type = asset.mediaType
        
        let dispatchGroup = DispatchGroup()
        
        // Upload original source
        var urlOrigin: URL?
        
        dispatchGroup.enter()
        if type == .image {
            uploadImageAndUpdateProgessUI(imageAsset, cellUpdateAt: indexPath) { (urlImage, error) in
                if error != nil {
                    print("Error: ", error!)
                    dispatchGroup.leave()
                    return
                }
                
                urlOrigin = urlImage
                dispatchGroup.leave()
            }
        } else if type == .video {
            uploadVideoAndUpdateProgessUI(asset, cellUpdateAt: indexPath) { (urlVideo, error) in
                if error != nil {
                    print("Error: ", error!)
                    dispatchGroup.leave()
                    return
                }
                
                urlOrigin = urlVideo
                dispatchGroup.leave()
            }
        }
        
        // Upload thumbnail image
        var urlThumbnail: URL?
        
        dispatchGroup.enter()
        guard let thumbnail = imageAsset.resize(width: 200) else {
            return
        }
        
        StorageController.uploadImage(thumbnail) { (uploadTask) in
            uploadTask.observe(.success) { (snapshot) in
                snapshot.reference.downloadURL { (urlThumb, error) in
                    if error != nil {
                        print("Error: ", error!.localizedDescription)
                        dispatchGroup.leave()
                        return
                    }
                    urlThumbnail = urlThumb
                    dispatchGroup.leave()
                }
            }
            
            uploadTask.observe(.failure) { (snapshot) in
                urlThumbnail = nil
                dispatchGroup.leave()
            }
        }
        
        // Update message with url in storage
        dispatchGroup.notify(queue: .main) {

            guard let cell = self.tableMessages.cellForRow(at: indexPath) as? BubbleBaseChat else {
                return
            }
            cell.progressBar.isHidden = true
            
            guard let safeMessUID = uid,
                  let safeUrlOrigin = urlOrigin?.absoluteString,
                  let safeUrlThumbnail = urlThumbnail?.absoluteString else {
                return
            }
            
            DatabaseController.updateMessage(
                safeMessUID,
                self.group.uid!,
                fields: [
                    "content": safeUrlOrigin,
                    "thumbnail": safeUrlThumbnail
                ]
            )
        }
    }
    
    internal func uploadVideoAndUpdateProgessUI(_ asset: PHAsset, cellUpdateAt indexPath: IndexPath, completion: @escaping (_ urlInStorage: URL?, _ error: String?) -> Void) {
        
        StorageController.uploadVideo(asset) { (uploadTask) in
            
            // Update progress UI
            uploadTask.observe(.progress) { (snapshot) in

                if let videoCell = self.tableMessages.cellForRow(
                    at: indexPath) as? BubbleVideoChat {

                    DispatchQueue.main.async {
                        videoCell.progressBar.isHidden = false
                        videoCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount)
                    }
                }
            }
            
            // Get link if success
            uploadTask.observe(.success) { (snapshot) in
                snapshot.reference.downloadURL { (url, error) in
                    return completion(url, error?.localizedDescription)
                }
            }
            
            // Fail
            uploadTask.observe(.failure) { (snapshot) in
                return completion(nil, snapshot.error?.localizedDescription)
            }
        }
    }
    
    internal func uploadImageAndUpdateProgessUI(_ image: UIImage, cellUpdateAt indexPath: IndexPath, completion: @escaping (_ urlInStorage: URL?, _ error: String?) -> Void) {
        
        StorageController.uploadImage(image) { (uploadTask) in
            
            // Update UI
            uploadTask.observe(.progress) { (snapshot) in
                if let imgCell = self.tableMessages.cellForRow(
                    at: indexPath) as? BubbleImageChat {
                    
                    DispatchQueue.main.async {
                        imgCell.progressBar.isHidden = false
                        imgCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount)
                    }
                }
            }
            
            // Get link if success
            uploadTask.observe(.success) { (snapshot) in
                snapshot.reference.downloadURL { (url, error) in
                    return completion(url, error?.localizedDescription)
                }
            }
            
            // Failure
            uploadTask.observe(.failure) { (snapshot) in
                return completion(nil, snapshot.error?.localizedDescription)
            }
        }
    }
}
