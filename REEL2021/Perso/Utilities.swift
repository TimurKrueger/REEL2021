//
//  Utilities.swift
//  REEL2021
//
//  Created by Louis Hakim on 10.12.20.
//

import Foundation
import UIKit

class Utilities {
    
    //MARK: Styling UITextField
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width/2 , height: 1)
        bottomLine.backgroundColor = UIColor.init(red: 28/255, green: 32/255, blue: 67/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the Line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    //MARK: Styling UIButton
    static func styleFilledButton(_ button: UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 28/255, green: 32/255, blue: 67/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button: UIButton) {
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.init(red: 28/255, green: 32/255, blue: 67/255, alpha: 1).cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.init(red: 28/255, green: 32/255, blue: 67/255, alpha: 1)
    }
    
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z||d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    // MARK: Styling UITextView
    static func styleTextView(_ textview: UITextView) {
        textview.layer.cornerRadius = 10
        textview.layer.borderWidth = 2
        textview.layer.borderColor = UIColor.init(red: 28/255, green: 32/255, blue: 67/255, alpha: 1).cgColor
        textview.layer.shadowColor = UIColor.black.cgColor
        textview.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        textview.layer.shadowOpacity = 0.4
        textview.layer.shadowRadius = 20
    }
        
}
