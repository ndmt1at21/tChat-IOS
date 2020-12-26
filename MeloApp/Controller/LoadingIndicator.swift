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
    
    let windowApp = UIApplication.shared.windows[0]
    let animationView = AnimationView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func startAnimation() {
        guard let view = self.loadViewFromNib(nibName: "LoadingIndicator") else {
            return
        }
        
        view.frame = windowApp.bounds
        windowApp.addSubview(view)
        blurEffect.alpha = 0.4
        animationView.frame = loadingView.bounds
        loadingView.addSubview(animationView)
        
        animationView.animation = Animation.named("loadingAnimation")
        animationView.loopMode = .loop
        animationView.play()

    }
    
    func stopAnimation() {
        animationView.stop()
        animationView.removeFromSuperview()
        loadingView.removeFromSuperview()
        blurEffect.removeFromSuperview()
        contentView.removeFromSuperview()
    }
}
