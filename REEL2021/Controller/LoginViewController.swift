//
//  LoginViewController.swift
//  Eurobase
//
//  Created by Louis Hakim on 28.12.20.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginNavigationController: UINavigationController {
    
}

class TabBarController : UITabBarController {
    
    @IBOutlet weak var signOut: UIButton!
    
    
    // MARK: Two navigation controllers with a view controller and a tabbar controller are not compatible, so the tab bar is the main controller and the login controller is simply presented on top of the home view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: check if user is already logged in
        Auth.auth().addStateDidChangeListener { (auth, user) in
           
            // MARK: if no user is logged in, then the Login view controller is presented
            if user == nil {
                let destination = self.storyboard!.instantiateViewController(identifier: "LoginNavigationController") as! LoginNavigationController
                self.present(destination, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        //Signing out the user
        do {
       try Auth.auth().signOut()
            
        // MARK: If signing out is successful, the login view controller should be presented
        let destination = self.storyboard!.instantiateViewController(identifier: "LoginNavigationController") as! LoginNavigationController
            self.present(destination, animated: true, completion: nil)
        } catch let error {
            print("Failed to sign out user")
        }
    }
    
    
}


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLoginTextField: UITextField!
    @IBOutlet weak var passwordLoginTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: setting up the UIElements
        setUpElements()
    }
    
    func setUpElements() {
        
        // MARK: This line hides the error label
        errorLabel.alpha = 0
        
        // MARK: for detailed definitions look up the Utilities file
       // Utilities.styleTextField(emailLoginTextField)
       // Utilities.styleTextField(passwordLoginTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    
    @IBAction func logInTapped(_ sender: Any) {
    
        // MARK: Create cleaned versions of the text fields
        let email = emailLoginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordLoginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        // MARK: Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
            
                // MARK: If signing in was successful, the login view controller shoul be dismissed so that the tab bar controller is seen
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleLogin() {
        print("Handle login...")
    }
}
