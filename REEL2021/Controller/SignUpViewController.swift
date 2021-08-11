//
//  SignUpViewController.swift
//  REEL2021
//
//  Created by Louis Hakim on 02.12.20.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase


class SignUpViewController: UIViewController {
 
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Check the fiels and validate that the data is correct. If everything ist correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || signUpEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || signUpPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  {
            return "Please fill in all fields."
        }
        
        // Check if password is valid
        let cleanedPassword = signUpPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
       /* if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters long, contains a special character and a number."
        }*/
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            // There was an error in the fields
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = signUpEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = signUpPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            // create an user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                
                // Check for errors
                if let error = error {
                    //There is an error creating the user
                    self.showError("Error creating user")
                }
                else {
                    // User created successfully, now store the first name and last name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname":firstName,"lastname":lastName, "uid":result!.user.uid]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data")
                        }
                    }
                    // Transition to the home screen
                    self.transitionHome()
                }
            }
    }
}
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionHome() {
        
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        subscribeToKeyboardNotificationsShow()
        subscribeToKeyboardNotificationsHide()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text!.isEmpty {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotificationsShow()
        unsubscribeToKeyboardNotificationsHide()
    }
    
    func setUpElements() {
        
        errorLabel.alpha = 0 // hiding errorLabel
        
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(signUpEmailTextField)
        Utilities.styleTextField(signUpPasswordTextField)
        Utilities.styleFilledButton(signUpButton)
        
    }
    
    // KEYBOARD (UN)SUBSCRIPTION
    func subscribeToKeyboardNotificationsShow() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardNotificationsHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotificationsShow() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotificationsHide() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
      @objc func keyboardWillHide(_ notification: Notification) {
        if (signUpPasswordTextField.isEditing && view.frame.origin.y != 0) {
        view.frame.origin.y = 0
        }
}
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if (signUpPasswordTextField.isEditing && view.frame.origin.y == 0) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
}
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height - 5.0
    }
}
