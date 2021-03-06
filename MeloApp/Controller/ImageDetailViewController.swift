//
//  ImageDetailViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/25/20.
//

import UIKit

class ImageDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var zoomingImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var customNavBar: NavigationBarNormal!
    
    var originUrlImage: URL?
    var thumbnail: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.delegate = self
        
        progressBar.progress = 0
        
        setupImage()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imageDidDoubleTaped(_:)))
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTapsRequired = 2
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(doubleTap)
        
        zoomingImage.isUserInteractionEnabled = true
        zoomingImage.addGestureRecognizer(doubleTap)
        
        setupCustomNavBar()
    }

    private func setupCustomNavBar() {
        customNavBar.titleLabel.isHidden = true
        customNavBar.delegate = self
        customNavBar.backgroundColor = .black
        customNavBar.backButton.backgroundColor = .black
        customNavBar.backButton.tintColor = .white
    }
    
    @objc func imageDidDoubleTaped(_ sender: UITapGestureRecognizer) {

        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(2.0, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // update frame ..
        scrollView.layoutSubviews()
        
        // update image inset base on scrollView frame
        // not use scrollView.layout.. -> not update new frame of scrollView
        // -> have more inset around imageView
        updateInsetImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func setupImage() {
        let imgLoading = ImageLoading()
        imgLoading.loadingImageAndCaching(target: zoomingImage, with: originUrlImage?.absoluteString, placeholder: thumbnail) { (downloaded, totalSize) in
            DispatchQueue.main.async {
                self.progressBar.isHidden = false
                self.progressBar.progress = Float(downloaded) / Float(totalSize)
            }
        } completion: { (error) in
            self.progressBar.isHidden = true
        }
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingImage
    }
    
    // https://stackoverflow.com/questions/39460256/uiscrollview-zooming-contentinset
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
       updateInsetImageView()
    }
    
    func updateInsetImageView() {
        if scrollView.zoomScale > 1 {
            if let image = zoomingImage.image {

                let ratioW = zoomingImage.frame.width / image.size.width
                let ratioH = zoomingImage.frame.height / image.size.height

                let ratio = ratioW < ratioH ? ratioW : ratioH

                // width, height show in imageView (zoomingImage)
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio

                let left = 0.5 * (newWidth * scrollView.zoomScale > zoomingImage.frame.width ? (newWidth - zoomingImage.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > zoomingImage.frame.height ? (newHeight - zoomingImage.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}

extension ImageDetailViewController: NavigationBarNormalDelegate {
    func navigationBar(_ naviagtionBarNormal: NavigationBarNormal, backPressed sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
}
