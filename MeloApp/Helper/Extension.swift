//
//  Extension.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import UIKit
import Photos

extension UIView {
    func shadow(_ x: Double, _ y: Double, _ radius: CGFloat, _ color: CGColor) {
        let offset = CGSize(width: x, height: y)
        layer.shadowOpacity = 1
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowColor = color
    }
    
    enum BorderPosition {
        case top
        case left
        case right
        case bottom
        case all
    }
    
    func border(_ pos: BorderPosition, _ borderWidth: CGFloat, _ color: CGColor, _ radius: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        border.borderWidth = 0
        border.style = .none
   
        switch pos {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderWidth)
        case .right:
            border.frame = CGRect(x: self.frame.width - borderWidth, y: 0, width: borderWidth, height: self.frame.height)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - borderWidth - 2, width: self.frame.width, height: borderWidth)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.height)
        default:
            layer.borderColor = color
            layer.borderWidth = borderWidth
        }
       
        layer.cornerRadius = radius
        layer.addSublayer(border)
        layer.masksToBounds = true
    }
}

extension UIColor {
    convenience init(_ hex: String, _ alpha: CGFloat) {
        if !hex.hasPrefix("#") {
            self.init()
            return
        }
        
        let index = hex.index(after: hex.startIndex);
        let hexStr = String(hex[index...])
        let hexColor = UInt32(hexStr, radix: 16)
                            
        if (hexColor == nil) {
            self.init()
            return
        }
        
        let red = CGFloat((hexColor! & 0xFF0000) >> 16) / 255
        let green = CGFloat((hexColor! & 0x00FF00) >> 8) / 255
        let blue = CGFloat((hexColor! & 0x0000FF)) / 255

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


extension UIView {
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}


extension CALayer {
    func shadow(_ x: Double, _ y: Double, _ radius: CGFloat, _ color: CGColor) {
        let offset = CGSize(width: x, height: y)
        self.shadowOpacity = 1
        shadowOffset = offset
        shadowRadius = radius
        shadowColor = color
    }
}


extension UIView {
    func addGradientLayer(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber]) {

        let gradientView = GradientView(frame: self.bounds)
        gradientView.colors = colors
        gradientView.startPoint = startPoint
        gradientView.endPoint = endPoint
        gradientView.locations = locations
        
        gradientView.isUserInteractionEnabled = false
        self.insertSubview(gradientView, at: 0)
    }
}

class GradientView: UIView {

    var colors: [CGColor] = [] {
        didSet {
            gradientLayer.colors = colors
            setNeedsDisplay()
        }
    }
    
    var startPoint: CGPoint = CGPoint() {
        didSet {
            gradientLayer.startPoint = startPoint
            setNeedsDisplay()
        }
    }
    
    var endPoint: CGPoint = CGPoint() {
        didSet {
            gradientLayer.endPoint = endPoint
            setNeedsDisplay()
        }
    }
    
    var locations: [NSNumber] = [] {
        didSet {
            gradientLayer.locations = locations
            setNeedsDisplay()
        }
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gradientLayer.frame = self.bounds
    }
}

func alertError(title: String, message: String, toFocus: UITextField?, vc: UIViewController) {
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
    )
    
    let action = UIAlertAction(
        title: "OK",
        style: .default) { _ in
        toFocus?.becomeFirstResponder()
    }
    alert.addAction(action)
    vc.present(alert, animated: true, completion: nil)
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}

extension Date {
    var milisecondSince1970: UInt64 {
        return UInt64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(miliseconds: UInt64) {
        self = Date(timeIntervalSince1970: TimeInterval(miliseconds) / 1000)
    }
}

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    func getImage() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { (result, _) in
            image = result!
        }
        
        return image
    }
}

extension UIImage {
    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resize(targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(
                width: size.width * heightRatio,
                height: size.height * heightRatio
            )
        } else {
            newSize = CGSize(
                width: size.width * widthRatio,
                height: size.height * widthRatio
            )
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func resize(width: CGFloat) -> UIImage? {
        let height = self.size.width * self.size.height / width
        return self.resize(targetSize: CGSize(width: width, height: height))
    }
}


func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
    let asset = AVAsset(url: fileUrl)
    return thumbnailImageForAsset(asset, CMTime(value: 1, timescale: 60))
}

func thumbnailImageForAsset(_ asset: AVAsset, _ time: CMTime) -> UIImage? {
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
        let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: thumbnailCGImage)
        
    } catch let err {
        print(err)
    }
    
    return nil
}

func readPlist(forResource path: String?) -> [[String:Any]]? {
    if let path = Bundle.main.path(forResource: path, ofType: "plist") {
        return NSArray(contentsOfFile: path) as? [[String:Any]]
    }
    
    return []
}

class RadialGradient: UIView {
    var startCenter: CGPoint = CGPoint()
    var endCenter: CGPoint = CGPoint()
    var startRadius: CGFloat = CGFloat()
    var endRadius: CGFloat = CGFloat()
    var gradient: CGGradient?
    var options: CGGradientDrawingOptions = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(startCenter: CGPoint, endCenter: CGPoint, startRadius: CGFloat, endRadius: CGFloat, gradient: CGGradient?, options: CGGradientDrawingOptions) {
        super.init(frame: .zero)
        
        self.startCenter = startCenter
        self.endCenter = endCenter
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.gradient = gradient
        self.options = options
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        context.drawRadialGradient(gradient!, startCenter: startCenter, startRadius: startRadius, endCenter: endCenter, endRadius: endRadius, options: options)
    }
}

