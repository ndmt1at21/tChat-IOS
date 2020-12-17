//
//  Extension.swift
//  MeloApp
//
//  Created by Minh Tri on 12/15/20.
//

import UIKit

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
}
