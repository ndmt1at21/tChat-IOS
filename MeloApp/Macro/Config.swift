//
//  Config.swift
//  MeloApp
//
//  Created by Minh Tri on 12/24/20.
//

import Foundation
import Kingfisher

var cache: ImageCache {
    let cache = ImageCache.default
    cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 1024
    cache.memoryStorage.config.countLimit = 1000
    
    return cache
}

