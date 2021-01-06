//
//  StickerPickerView.swift
//  MeloApp
//
//  Created by Minh Tri on 12/31/20.
//

import UIKit


import UIKit

protocol StickerPickerViewDelegate: class {
    func stickerPicker(_ stickerPicker: StickerPickerView, didSelectedAt sticker: Sticker)
    func numberOfStickerInRow(_ stickerPicker: StickerPickerView) -> Int
}

class StickerPickerView: UIView {

    @IBOutlet weak var stickerPicker: StickerPicker!
    
    weak var delegate: StickerPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
        loadData()
    }

    private func loadView() {
        guard let view = self.loadViewFromNib(nibName: "StickerPickerView") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
        stickerPicker.delegate = self
    }
    
    private func loadData() {
        guard let data = readPlist(forResource: "stickerList") else { return }
        
        var allStickers: [[Sticker]] = []
        for category in data {
            let stickers = category["stickers"] as! [String]
            let stickersModel = stickers.map{ Sticker(content: $0, type: .sticker)}
            allStickers.append(stickersModel)
        }
        
        stickerPicker.stickerCategory = allStickers
    }
}

extension StickerPickerView: StickerPickerDelegate {
    func widthForSticker(_ stickerPicker: StickerPicker) -> Int {
        return 100
    }
    
    func stickerPicker(_ stickerPicker: StickerPicker, didSelectedSticker sticker: Sticker) {
        delegate?.stickerPicker(self, didSelectedAt: sticker)
    }
}
