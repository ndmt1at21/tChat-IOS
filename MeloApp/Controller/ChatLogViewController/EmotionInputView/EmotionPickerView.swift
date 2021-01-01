//
//  EmotionPickerView.swift
//  MeloApp
//
//  Created by Minh Tri on 12/31/20.
//

import UIKit

protocol EmotionPickerViewDelegate: class {
    func emotionPicker(_ emotionPicker: EmotionPickerView, didSelectedAt sticker: Sticker)
    func numberOfEmotionInRow(_ emotionPicker: EmotionPickerView) -> Int
}

class EmotionPickerView: UIView {

    @IBOutlet weak var stickerPicker: StickerPicker!
    
    weak var delegate: EmotionPickerViewDelegate?
    
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
        guard let view = self.loadViewFromNib(nibName: "EmotionPickerView") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
        stickerPicker.delegate = self
    }
    
    private func loadData() {
        guard let data = readPlist(forResource: "emojiList") else { return }
        
        var allEmojis: [[Sticker]] = []
        for category in data {
            let emojis = category["emojis"] as! [String]
            let emojisModel = emojis.map{ Sticker(content: $0, type: .emoji)}
            allEmojis.append(emojisModel)
        }
        
        stickerPicker.stickerCategory = allEmojis
    }
}

extension EmotionPickerView: StickerPickerDelegate {
    func stickerPicker(_ stickerPicker: StickerPicker, didSelectedSticker sticker: Sticker) {
        delegate?.emotionPicker(self, didSelectedAt: sticker)
    }
    
    func numberOfStickerInRow(_ emotionPicker: StickerPicker) -> Int {
        return delegate?.numberOfEmotionInRow(self) ?? 0
    }
}
