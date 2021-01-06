//
//  ToolbarEmotion.swift
//  MeloApp
//
//  Created by Minh Tri on 1/5/21.
//

import UIKit

class ToolbarEmotion: UIView {

    
    @IBOutlet weak var containerView: UIStackView!
    
    @IBOutlet weak var emoji1: UIImageView!
    @IBOutlet weak var emoji2: UIImageView!
    @IBOutlet weak var emoji3: UIImageView!
    @IBOutlet weak var emoji4: UIImageView!
    @IBOutlet weak var emoji5: UIImageView!
    @IBOutlet weak var emoji6: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadingView()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadingView()
        setupAction()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        var emojis = [emoji1, emoji2, emoji3, emoji4, emoji5, emoji6]
        
        emojis = emojis.map({ (emoji) -> UIImageView? in
            emoji!.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).translatedBy(x: 10, y: 10)
            return emoji
        })
        
        var index: Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            
            UIView.animateKeyframes(withDuration: 0.7, delay: 0, options: []) {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                    emojis[index]!.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
                    emojis[index]!.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            
            
            if index == 5 {
                timer.invalidate()
            }
            index += 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.height / 2
        self.shadow(0, 2, 5, UIColor.systemGray3.cgColor)
    }
    
    private func loadingView() {
        guard let view = self.loadViewFromNib(nibName: "ToolbarEmotion") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleEmotionTap))
        
        let stack = containerView.subviews.first!
        containerView.addGestureRecognizer(tap)
    }
    
    @objc func handleEmotionTap(_ sender: UITapGestureRecognizer, index: Int) {
      print("ios hay ma kho nhu cc")
    }
}
