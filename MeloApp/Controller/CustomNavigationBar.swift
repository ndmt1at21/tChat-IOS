//
//  CustomNavigationBar.swift
//  MeloApp
//
//  Created by Minh Tri on 12/20/20.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 200)
    }
}
