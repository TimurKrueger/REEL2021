//
//  ViewController.swift
//  REEL2021
//
//  Created by Louis Hakim on 19.11.20.
//

import UIKit
import Firebase
import FirebaseAuth
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var SignInButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInTapped(_ sender: Any) {
        
        activityIndicator.startAnimating()
        // Create cleaned versions of the text field
        let email  = loginEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = loginPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.ErrorLabel.text = error!.localizedDescription
                self.ErrorLabel.alpha = 1
                
            } else {
                let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()

            }
        }
        
    }
    
    
    func setUpElements() {
        
        ErrorLabel.alpha = 0
        
        Utilities.styleTextField(loginEmail)
        Utilities.styleTextField(loginPassword)
        Utilities.styleFilledButton(SignInButton)
    }
    
    
    //allow the user to write in the Text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // Figure out what the new text will be, if we return true
        var newText = loginEmail.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        var newText1 = loginPassword.text! as NSString
        newText1 = newText1.replacingCharacters(in: range, with: string) as NSString
        
        // returning true gives the text field permission to change its text
        return true;

    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}

