//
//  PageControlView.swift
//  pickeremoji
//
//  Created by Minh Tri on 12/30/20.
//

import UIKit

protocol PageControlViewDataSource: class {
    func numberOfPages(_ pageControlView: PageControlView) -> Int
    func pageControllView(_ pageControlView: PageControlView, sizeForCellAt itemPos: Int) -> CGSize
}

protocol PageControlViewDelegate: class {
    func pageControlView(_ pageControlView: PageControlView, didSelectedPageAt item: Int)
}

class PageControlView: UIView {
    
    @IBOutlet weak var collectionPages: UICollectionView!
    
    var stickers: [Sticker] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionPages.reloadData()
                self.collectionPages.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .right)
            }
        }
    }
    
    var numberOfPages: Int = 0
    var currentPage: Int = 0 {
        didSet {
            if currentPage < 0 || currentPage >= numberOfPages { return }
            
            collectionPages.selectItem(at: IndexPath(item: currentPage, section: 0), animated: true, scrollPosition: .right)
        }
    }
    
    private var isFirstRun: Bool = true
    
    weak var dataSource: PageControlViewDataSource?
    weak var delegate: PageControlViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadingView()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadingView()
        setupCollectionView()
    }
    
    private func loadingView() {
        guard let view = self.loadViewFromNib(nibName: "PageControlView") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupCollectionView() {
        collectionPages.delegate = self
        collectionPages.dataSource = self
        collectionPages.decelerationRate = .normal
        
        let nib = UINib(nibName: "PageControlCell", bundle: .main)
        collectionPages.register(nib, forCellWithReuseIdentifier: "PageControlCell")
    }
    
    func cellForItemPage(at itemPos: Int) -> PageControlCell? {
        return collectionPages.cellForItem(at: IndexPath(item: itemPos, section: 0)) as? PageControlCell
    }
}

// MARK: - CollectionDelegate
extension PageControlView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionPages.cellForItem(at: indexPath) as! PageControlCell
        let left = (cell.frame.minX - collectionView.contentOffset.x)
        
        if left <= cell.bounds.width {
            DispatchQueue.main.async {
                self.collectionPages.scrollToItem(
                    at: IndexPath(item: max(indexPath.item - 2, 0), section: 0),
                    at: .left,
                    animated: true
                )
            }
        } else if left >= collectionView.frame.maxX - cell.bounds.width * 2 {
            DispatchQueue.main.async {
                self.collectionPages.scrollToItem(
                    at: IndexPath(item: min(indexPath.item + 2, self.numberOfPages - 1), section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
        }
        
        currentPage = indexPath.item
        delegate?.pageControlView(self, didSelectedPageAt: currentPage)
    }
}

// MARK: - CollectionDataSource
extension PageControlView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfPages = dataSource?.numberOfPages(self) ?? 0
        return numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionPages.dequeueReusableCell(withReuseIdentifier: "PageControlCell", for: indexPath) as! PageControlCell
        cell.stickerModel = stickers[indexPath.item]

        return cell
    }
}

// MARK: - CollectionFlowLayout
extension PageControlView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource?.pageControllView(self, sizeForCellAt: indexPath.item) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
