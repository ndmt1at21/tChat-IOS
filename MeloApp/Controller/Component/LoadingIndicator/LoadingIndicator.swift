//
//  LoadingIndicator.swift
//  MeloApp
//
//  Created by Minh Tri on 12/17/20.
//

import UIKit
import Lottie

class LoadingIndicator: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    let animationView = AnimationView()
    
    enum ColorIndicator {
        case white
        case blue
    }
    
    var colorIndicator: ColorIndicator = .blue {
        didSet {
            if colorIndicator == .blue {
                animationView.animation = Animation.named("loadingAnimation")
            } else {
                animationView.animation = Animation.named("loadingAnimation-white")
            }
            
        }
    }
    
    var isTurnBlurEffect: Bool = true {
        didSet {
            if !isTurnBlurEffect {
                blurEffect.isHidden = true
            }
        }
    }
    
    var blurStyle: UIBlurEffect.Style = .systemMaterial {
        didSet {
            let blur = UIBlurEffect(style: blurStyle)
            blurEffect.effect = blur
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        guard let view = self.loadViewFromNib(nibName: "LoadingIndicator") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
 
        blurEffect.alpha = 0.4
        animationView.frame = loadingView.bounds
        loadingView.addSubview(animationView)
        
        animationView.animation = Animation.named("loadingAnimation")
        animationView.loopMode = .loop
    }
    
    func startAnimation() {
        DispatchQueue.main.async {
            self.animationView.play()
        }
    }
    
    func stopAnimation() {
        animationView.stop()
    }
}
