//
//  ListStickerCollectionViewCell.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

protocol ListStickerCollectionCellDelegate: class {
    func didSelectedSticker(at sticker: Sticker)
}

protocol ListStickerCollectionCellDataSource: class {
  func numberOfStickersInRow() -> Int
}

let kGapCollectionCell: CGFloat = 0
let kInsetCollectionCell: CGFloat = 0

class ListStickerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var listStickerCollection: UICollectionView!

    var stickers: [Sticker] = [] {
        didSet {
            listStickerCollection.reloadData()
        }
    }
    weak var delegate: ListStickerCollectionCellDelegate?
    weak var dataSource: ListStickerCollectionCellDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: "StickerCell", bundle: .main)
        listStickerCollection.register(nib, forCellWithReuseIdentifier: "StickerCell")
        
        listStickerCollection.delegate = self
        listStickerCollection.dataSource = self
        listStickerCollection.contentInset = UIEdgeInsets(
            top: kInsetCollectionCell,
            left: kInsetCollectionCell,
            bottom: kInsetCollectionCell,
            right: kInsetCollectionCell
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listStickerCollection.collectionViewLayout.invalidateLayout()
        DispatchQueue.main.async {
            self.listStickerCollection.reloadData()
        }
    }
}

extension ListStickerCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = listStickerCollection.cellForItem(at: indexPath) as! StickerCell
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            cell.backgroundColor = UIColor.systemGray5
        } completion: { (_) in
            cell.backgroundColor = UIColor.white
        }
        
        delegate?.didSelectedSticker(at: stickers[indexPath.item])
    }
}

extension ListStickerCollectionViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = listStickerCollection.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
       
        cell.stickerModel = stickers[indexPath.item]
        return cell
    }
    
    override func prepareForReuse() {
        stickers = []
    }
}

extension ListStickerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let nStickerInRow = dataSource?.numberOfStickersInRow() ?? 1
        
        let widthAfterInset = view.bounds.width - 2 * kInsetCollectionCell
        let widthAfterGap = widthAfterInset - CGFloat(nStickerInRow - 1) *
            kGapCollectionCell
        let widthSticker = widthAfterGap / CGFloat(nStickerInRow)
        
        return CGSize(width: widthSticker, height: widthSticker)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
