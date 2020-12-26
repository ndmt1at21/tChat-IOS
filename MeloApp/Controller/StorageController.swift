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
        progressBlock: @escaping (_ snapshot: StorageTaskSnapshot) -> Void) {
        
        let refImageCollection = Storage.storage().reference().child("images")
        let uid = UUID().uuidString + "-\(Date().milisecondSince1970).jpeg"
        let refImage = refImageCollection.child(uid)
        
        let uploadTask = refImage.putData(image.jpegData(compressionQuality: 0.7)!)
       
        uploadTask.observe(.progress, handler: progressBlock)
    }
    
    static func uploadVideo (
        _ asset: PHAsset,
        progressBlock: @escaping (_ snapshot: StorageTaskSnapshot) -> Void) {
  
        let refVideoCollection = Storage.storage().reference().child("videos")
        
        let uid = UUID().uuidString + "-\(Date().milisecondSince1970).mov"
        let refVideo = refVideoCollection.child(uid)
        
        asset.getURL { (url) in
            guard let localUrl = url else { return }
            
            let uploadTask = refVideo.putFile(from: localUrl)
                    
            uploadTask.observe(.progress, handler: progressBlock)
        }
    }
}
