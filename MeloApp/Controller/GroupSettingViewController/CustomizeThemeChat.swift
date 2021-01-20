//
//  CustomizeChat.swift
//  MeloApp
//
//  Created by Minh Tri on 1/19/21.
//

import UIKit


protocol CustomizeThemeChatDelegate {
    func customizeThemeChat(_ customizeThemeChat: CustomizeThemeChat, selectedAt theme: Theme)
}

class CustomizeThemeChat: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionCustomChat: UICollectionView!
    
    var themes: [Theme] = []
    
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
        guard let view = self.loadViewFromNib(nibName: "CustomizeThemeChat") else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupView() {
        collectionCustomChat.register(UINib(nibName: "CustomizeThemeChatCell", bundle: .main), forCellWithReuseIdentifier: K.cellID.customizeChatCell)
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
    }
}

extension CustomizeThemeChat: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionCustomChat.dequeueReusableCell(withReuseIdentifier: K.cellID.customizeChatCell, for: indexPath) as! CustomizeThemeChatCell
        
        if themes[indexPath.item].colors == nil {
            return UICollectionViewCell()
        }
        
        let colors = themes[indexPath.item].colors!.map{ UIColor($0, 1) } as CFArray
        
        let radialGradient = RadialGradient(
            startCenter: CGPoint(x: bounds.width / 2, y: bounds.width / 2),
            endCenter: CGPoint(x: bounds.width / 2, y: bounds.width / 2),
            startRadius: 10,
            endRadius: 20,
            gradient: CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 0.5, 1]
            ),
            options: [CGGradientDrawingOptions.drawsAfterEndLocation, CGGradientDrawingOptions.drawsAfterEndLocation])
        cell.image.addSubview(radialGradient)
        
        return cell
    }
    
}

extension CustomizeThemeChat: UICollectionViewDelegateFlowLayout {
    
}
