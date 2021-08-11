//
//  DesignableView.swift
//  REEL2021
//
//  Created by Louis Hakim on 02.12.20.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat = 0.0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable var shadowOffsetY: CGFloat = 0.0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
    
}
