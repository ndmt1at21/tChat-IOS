//
//  StickerPicker+PageControl.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

// MARK: - PageControlDelegate
extension StickerPicker: PageControlViewDelegate {
    func pageControlView(_ pageControlView: PageControlView, didSelectedPageAt item: Int) {
        stickerCategoryCollection.scrollToItem(at: IndexPath(item: item, section: 0), at: .top, animated: true)
    }
}

// MARK: - PageControlDataSource
extension StickerPicker: PageControlViewDataSource {
    func numberOfPages(_ pageControlView: PageControlView) -> Int {
        return stickerCategory.count    
    }
    
    func pageControllView(_ pageControlView: PageControlView, sizeForCellAt itemPos: Int) -> CGSize {
        let height = pageControl.frame.height
        return CGSize(width: height, height: height)
    }
}
