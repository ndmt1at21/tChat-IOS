//
//  NavigationBarChatLog.swift
//  MeloApp
//
//  Created by Minh Tri on 1/2/21.
//

import UIKit
import MaterialComponents

protocol NavigationBarNormalDelegate: class {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton)
}

@IBDesignable
class NavigationBarNormal: UIView {
    
    @IBOutlet weak var backButton: MDCButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: NavigationBarNormalDelegate?
    
    var preferLarge: Bool = false {
        didSet {
            if preferLarge {
                titleLabel.font = .systemFont(ofSize: 25, weight: .medium)
            } else {
                titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadingView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadingView()
    }
    
    private func loadingView() {
        guard let view = self.loadViewFromNib(nibName: "NavigationBarNormal") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.delegate?.navigationBar(self, backPressed: sender)
        }
    }
}
