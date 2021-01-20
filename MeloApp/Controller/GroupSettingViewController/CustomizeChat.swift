//
//  CustomizeChat.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import UIKit


protocol CustomizeChatDelegate {
    func customizeChat(_ customizeChat: CustomizeThemeChat, selectedAt theme: Theme)
}

class CustomizeThemeChat: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionCustomChat: UICollectionView!
    
    var themes: [Theme]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadingView()
        setupView()
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadingView()
        setupView()
        fetchData()
    }
    
    private func loadingView() {
        guard let view = self.loadViewFromNib(nibName: "CustomizeChat") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupView() {
        collectionCustomChat.register(UINib(nibName: "CustomizeChatCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.customizeChatCell)
    }
    
    private func fetchData() {
        DatabaseController.getThemes { (themes) in
            self.themes = themes
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = 10
    }
}

extension CustomizeThemeChat: UICollectionViewDelegate {
    
}

extension CustomizeThemeChat: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}

extension CustomizeThemeChat: UICollectionViewDelegateFlowLayout {
    
}
