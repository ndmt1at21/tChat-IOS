//
//  ChatLogViewController+Networking.swift
//  MeloApp
//
//  Created by Minh Tri on 1/2/21.
//

import UIKit
import Photos

extension ChatLogViewController {
    internal func sendTextMessage(completion: @escaping (_ error: String?) -> Void) {
        guard var text = chatTextView.text else { return }
        
        text = text.trimmingCharacters(in: ["\n", " "])
        if text.count == 0 { return }
        
        guard let currentUser = AuthController.shared.currentUser else { return }
        let message = Message(
            currentUser.uid,
            Date().milisecondSince1970,
            TypeMessage.text,
            text
        )
        
        DatabaseController.sendMessage(message: message, to: group.uid!) { (error) in
            if error != nil {
                return completion(nil)
            }
            return completion(error)
        }
    }
    
    internal func sendImageAndVideoMessage(_ asset: PHAsset, _ localUID: StringUID) {
        guard let currentUser = AuthController.shared.currentUser else { return }

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
            uploadImageAndUpdateProgessUI(imageAsset, cellUpdateAt: currIndexPath) { (urlImage, error) in
                
                if error != nil {
                    print("Error: ", error!)
                    return
                }
                
                urlOrigin = urlImage
                dispatchGroup.leave()
            }
        } else if type == .video {
            uploadVideoAndUpdateProgessUI(asset, cellUpdateAt: currIndexPath) { (urlVideo, error) in
                if error != nil {
                    print("Error: ", error!)
                    return
                }
                
                urlOrigin = urlVideo
                dispatchGroup.leave()
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
            
            DatabaseController.sendMessage(message: message, to: self.group.uid!) { (error) in
                if error != nil { print(error!) }
            }
        }
    }
    
    internal func uploadVideoAndUpdateProgessUI(_ asset: PHAsset, cellUpdateAt indexPath: IndexPath, completion: @escaping (_ urlInStorage: URL?, _ error: String?) -> Void) {
        
        StorageController.uploadVideo(asset) { (snapshot) in
            if let videoCell = self.tableMessages.cellForRow(
                at: indexPath) as? BubbleVideoChat {

                DispatchQueue.main.async {
                    videoCell.progressBar.isHidden = false
                    videoCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
                }
            } else {
                return completion(nil, "Invalid indexPath")
            }
            
            snapshot.reference.downloadURL { (urlVideo, error) in
                completion(urlVideo, error?.localizedDescription)
            }
        }
    }
    
    internal func uploadImageAndUpdateProgessUI(_ image: UIImage, cellUpdateAt indexPath: IndexPath, completion: @escaping (_ urlInStorage: URL?, _ error: String?) -> Void) {
        
        StorageController.uploadImage(image) { (snapshot) in
            if let imgCell = self.tableMessages.cellForRow(
                at: indexPath) as? BubbleImageChat {
                
                DispatchQueue.main.async {
                    imgCell.progressBar.isHidden = false
                    imgCell.progressBar.progress = Float(snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount)
                }
            } else {
                return completion(nil, "Error indexPath")
            }

            snapshot.reference.downloadURL { (urlImage, error) in
                return completion(urlImage, error?.localizedDescription)
            }
        }
    }
    
    internal func sendLocalMessage(_ asset: PHAsset, _ localUID: StringUID, completion: @escaping (_ error: String?) -> Void) {
        guard let currentUser = AuthController.shared.currentUser else { return }
        
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
}
