//
//  EmotionInputView.swift
//  MeloApp
//
//  Created by Minh Tri on 12/31/20.
//

import UIKit

protocol EmotionInputViewDelegate: class {
    func emotionInput(_ emotionInput: EmotionInputView, didSelectedAt sticker: Sticker)
}

class EmotionInputView: UIView {
    static let kHeightEmotionInputView = UIScreen.main.bounds.height * 0.4
    
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var emotionPicker: UIButton!
    @IBOutlet weak var containerPicker: UIView!
    
    @IBOutlet weak var stickerPickerView: StickerPickerView!
    @IBOutlet weak var emotionPickerView: EmotionPickerView!
    
    weak var delegate: EmotionInputViewDelegate?
    var isShowInSuperview: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        loadView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    
        loadView()
        setupView()
    }
    
    private func loadView() {
        guard let view = self.loadViewFromNib(nibName: "EmotionInputView") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupView() {
        stickerButton.layer.cornerRadius = stickerButton.frame.height / 2
        emotionPicker.layer.cornerRadius = emotionPicker.frame.height / 2
        
        stickerPickerView.frame = containerPicker.bounds
        emotionPickerView.frame = containerPicker.bounds
        
        stickerPickerView.delegate = self
        emotionPickerView.delegate = self
        
        emotionPicker.backgroundColor = .systemGray4
        emotionPicker.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func stickerButtonPressed(_ sender: UIButton) {
        stickerButton.backgroundColor = .systemGray4
        stickerButton.setTitleColor(.black, for: .normal)
        
        emotionPicker.backgroundColor = .systemGray6
        emotionPicker.setTitleColor(.systemGray2, for: .normal)
        
        stickerPickerView.isHidden = false
        emotionPickerView.isHidden = true
    }
    
    @IBAction func emotionButtonPressed(_ sender: UIButton) {
        stickerButton.backgroundColor = .systemGray6
        stickerButton.setTitleColor(.systemGray2, for: .normal)
        
        emotionPicker.backgroundColor = .systemGray4
        emotionPicker.setTitleColor(.black, for: .normal)
        
        stickerPickerView.isHidden = true
        emotionPickerView.isHidden = false
    }
    
    override func didMoveToSuperview() {
        stickerPickerView.isUserInteractionEnabled = true
        emotionPickerView.isUserInteractionEnabled = true
        
    }
}

extension EmotionInputView: EmotionPickerViewDelegate {
    func emotionPicker(_ emotionPicker: EmotionPickerView, didSelectedAt sticker: Sticker) {
        delegate?.emotionInput(self, didSelectedAt: sticker)
    }
    
    func numberOfEmotionInRow(_ emotionPicker: EmotionPickerView) -> Int {
        return 8
    }
}

extension EmotionInputView: StickerPickerViewDelegate {
    func stickerPicker(_ stickerPicker: StickerPickerView, didSelectedAt sticker: Sticker) {
        delegate?.emotionInput(self, didSelectedAt: sticker)
    }
    
    func numberOfStickerInRow(_ stickerPicker: StickerPickerView) -> Int {
        return 5
    }
}
