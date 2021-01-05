//
//  StorageController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit
import Firebase
import Photos

class StorageController {
    static func uploadImage (
        _ image: UIImage,
        handler: @escaping (_ snapshot: StorageUploadTask) -> Void) {
        
        let refImageCollection = Storage.storage().reference().child("images")
        let uid = UUID().uuidString + "-\(Date().milisecondSince1970).jpeg"
        let refImage = refImageCollection.child(uid)
        
        let uploadTask = refImage.putData(image.jpegData(compressionQuality: 0.5)!)
       
        return handler(uploadTask)
    }
    
    static func uploadVideo (
        _ asset: PHAsset,
        handler: @escaping (_ snapshot: StorageUploadTask) -> Void) {
  
        let refVideoCollection = Storage.storage().reference().child("videos")
        let uid = UUID().uuidString + "-\(Date().milisecondSince1970).mov"
        let refVideo = refVideoCollection.child(uid)
        
        asset.getURL { (url) in
            // Bug???
            guard let localUrl = url else { return }
            
            let uploadTask = refVideo.putFile(from: localUrl)
            
            return handler(uploadTask)
        }
    }
}
