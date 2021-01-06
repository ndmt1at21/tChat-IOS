//
//  StickerPicker.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

protocol StickerPickerDelegate: class {
    func stickerPicker(_ stickerPicker: StickerPicker, didSelectedSticker sticker: Sticker)
    func widthForSticker(_ stickerPicker: StickerPicker) -> Int
}

class StickerPicker: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var stickerCategoryCollection: UICollectionView!
    @IBOutlet weak var pageControl: PageControlView!
    
    weak var delegate: StickerPickerDelegate?
    
    var stickerCategory : [[Sticker]] = [] {
        didSet {
            var thumb: [Sticker] = []
            stickerCategory.forEach { (category) in
               thumb.append(category.first!)
            }
            
            pageControl.stickers = thumb
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStickerPicker()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStickerPicker()
    }
    
    override func layoutSubviews() {
        stickerCategoryCollection.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.stickerCategoryCollection.reloadData()
        }
    }
    
    private func setupStickerPicker() {
        guard let view = self.loadViewFromNib(nibName: "StickerPicker") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
        let nib = UINib(nibName: "ListStickerCollectionViewCell", bundle: .main)
        stickerCategoryCollection.register(nib, forCellWithReuseIdentifier: "ListStickerViewCell")

        stickerCategoryCollection.delegate = self
        stickerCategoryCollection.dataSource = self
        stickerCategoryCollection.isPagingEnabled = true
        
        pageControl.delegate = self
        pageControl.dataSource = self
    }
}

extension StickerPicker: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = stickerCategoryCollection.dequeueReusableCell(withReuseIdentifier: "ListStickerViewCell", for: indexPath) as! ListStickerCollectionViewCell
        
        cell.delegate = self
        cell.dataSource = self

        cell.stickers = stickerCategory[indexPath.item]
        return cell
    }
}

extension StickerPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

// MARK: - Section Delegate DataSource For Cell
extension StickerPicker: ListStickerCollectionCellDataSource {
    func widthForSticker() -> Int {
        let width = delegate?.widthForSticker(self) ?? 0
        return width
    }
}

extension StickerPicker: ListStickerCollectionCellDelegate {
    func didSelectedSticker(at sticker: Sticker) {
        delegate?.stickerPicker(self, didSelectedSticker: sticker)
    }
}


// MARK: - Check Page Index
extension StickerPicker: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(stickerCategoryCollection.contentOffset.x / stickerCategoryCollection.frame.width)
        pageControl.currentPage = page
    }
}
