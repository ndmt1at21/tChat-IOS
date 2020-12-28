//
//  ImageLoading.swift
//  MeloApp
//
//  Created by Minh Tri on 12/24/20.
//

import UIKit
import Kingfisher

class ImageLoading {
    func loadingImageAndCaching(
        target: UIImageView,
        with url: String?,
        placeholder: UIImage?,
        progressHandler: DownloadProgressBlock?,
        completion: @escaping (_ error: String?) -> Void) {
        
        guard let urlStr = url else { return }
        guard let safeUrl = URL(string: urlStr) else { return }
        let cacheRes = ImageCache.default.isCached(forKey: urlStr)
        
        if cacheRes {
            target.kf.setImage(with: safeUrl)
            return completion(nil)
        }
        
        target.kf.setImage(
            with: safeUrl,
            placeholder: placeholder,
            options: [
                .cacheOriginalImage,
                .targetCache(cache)
            ],
            progressBlock: progressHandler
        ) { (result) in
            switch result {
            case .success(_):
                return completion(nil)
            case .failure(let value):
                return completion(value.localizedDescription)
            }
        }
    }
}
