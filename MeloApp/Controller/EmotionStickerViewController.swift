//
//  EmotionStickerViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/31/20.
//

import UIKit

class EmotionStickerViewController: UIViewController {
    
    @IBOutlet weak var emotionInputView: EmotionInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emotionInputView.delegate = self
    }
}

extension EmotionStickerViewController: EmotionInputViewDelegate {
    func emotionInput(_ emotionInput: EmotionInputView, didSelectedAt sticker: Sticker) {
        print(sticker)
    }
}
