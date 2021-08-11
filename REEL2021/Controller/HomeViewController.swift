//
//  HomeViewController.swift
//  REEL2021
//
//  Created by Louis Hakim on 10.12.20.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
    }
    
    
    func setUpElements() {
        Utilities.styleFilledButton(login)
        Utilities.styleHollowButton(signup)
    }
    
}
