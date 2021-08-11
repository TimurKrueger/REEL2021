//
//  ChatViewController.swift
//  REEL2021
//
//  Created by Louis Hakim on 11.12.20.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import FirebaseStorage
import FirebaseRemoteConfig




// MARK: - FCViewController

class FCViewController: UIViewController, UINavigationControllerDelegate, AuthUIDelegate {
    
    // MARK: Properties
    
    var ref: DatabaseReference!
    var messages: [DataSnapshot]! = []
    var msglength: NSNumber = 1000
    var storageRef: StorageReference!
    var remoteConfig: RemoteConfig!
    let imageCache = NSCache<NSString, UIImage>()
    var keyboardOnScreen = false
    var placeholderImage = UIImage(named: "ic_account_circle")
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    
    // MARK: Outlets
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var imageMessage: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var backgroundBlur: UIVisualEffectView!
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet var dismissImageRecognizer: UITapGestureRecognizer!
    @IBOutlet var dismissKeyboardRecognizer: UITapGestureRecognizer!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        // MARK: If we pass in true in this function, our app will assume that the user successfully authenitcated to our app
      //  self.signedInStatus(isSignedIn: true)
        
       
        
        //MARK: Configue Authentification
        configureAuth()
        // TODO: Handle what users see when view loads
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Config
    
    func configureAuth() {
        
        // MARK: this is to set up the google sign in
        let provider1: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider1
        

        // MARK: set up button for email/password sign in
        let provider2: [FUIAuthProvider] = [FUIEmailAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider2
        
        // MARK: listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            // MARK: refresh table data
            self.messages.removeAll(keepingCapacity: false)
            self.messagesTable.reloadData()
            
            // MARK: check if there is a current user
            if let activeUser = user {
                
                // MARK: check if the current app user is the current User
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                }
            } else {
                // MARK: user must sign in
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        })
    }
    
    func configureDatabase() {
        // MARK: First of all, we define a reference to the database we are using
        // MARK: Somehow, we had to specify the url of our database, since with the default syntax: Database.database().reference() did not access our database
        ref = Database.database(url: "https://reel2021-d280e-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        
        // MARK: creating a database listener in order to display it afterwards to our tableview
        // MARK: Here we add a listener as soon as a new child is added, meaning when a message is sent
        _refHandle = ref.child("messages").observe(.childAdded) { (snapshot: DataSnapshot) in
            self.messages.append(snapshot)
            self.messagesTable.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
            self.scrollToBottomMessage()
            
        }
    }
    
    func configureStorage() {
        // MARK: Create reference to location of our firebase storage
        storageRef = Storage.storage().reference()
    }
    
    deinit {
        // MARK: We need to remove the listener as soon as we deinitialize the view, in order to prevent excess memory use
        ref.child("messages").removeObserver(withHandle: _refHandle)
        
        // MARK: If the listener we create is no longer needed, we need to delete it
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    // MARK: Remote Config
    
    func configureRemoteConfig() {
        // MARK: create remote confi setting to enable developer mode
        let remoteConfigSetting = RemoteConfigSettings()
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = remoteConfigSetting
    }
    
    func fetchConfig() {
        var expirationDuration: Double = 3600
        
        // MARK: if developer mode, set expirattionDate to 0
       /* if remoteConfig.configSettings {
            expirationDuration = 0
        }*/
        // MARK: fetch config
        remoteConfig.fetch(withExpirationDuration: expirationDuration) { (status, error) in
            if status == .success {
                print("config fetched")
                self.remoteConfig.activate()
                    let friendlyMsgLength = self.remoteConfig["friendly_msg_length"]
                if friendlyMsgLength.source != .static {
                    self.msglength = friendlyMsgLength.numberValue
                    print("friend msg length config: \(self.msglength)")
                }
            } else {
                print("config not fetched")
                print(error)
            }
        }
    }
    
    // MARK: Sign In and Out
    
    func signedInStatus(isSignedIn: Bool) {
        signInButton.isHidden = isSignedIn
        signOutButton.isHidden = !isSignedIn
        messagesTable.isHidden = !isSignedIn
        messageTextField.isHidden = !isSignedIn
        sendButton.isHidden = !isSignedIn
        imageMessage.isHidden = !isSignedIn
        
        if (isSignedIn) {
            
            // remove background blur (will use when showing image messages)
            messagesTable.rowHeight = UITableView.automaticDimension
            messagesTable.estimatedRowHeight = 122.0
            backgroundBlur.effect = nil
            messageTextField.delegate = self
            
            // MARK: Configure the Database
            configureDatabase()
            // MARK: Configure the Storage
            configureStorage()
            
            // MARK: Configure our remote configuration
            configureRemoteConfig()
            fetchConfig()
        }
    }
    
    func loginSession() {
      let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
      self.present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: Send Message
    
    func sendMessage(data: [String:String]) {
        var mdata = data
        mdata[Constants.MessageFields.name] = displayName
        
        // MARK: childByAutoId is a function that generates a new child location using a unique key and returns a DatabaseReference to it. This unique key is prefixed with a client-generated timestamo so that the resulting list will be chronologically sorted
        ref.child("messages").childByAutoId().setValue(mdata)
        // like specifying "/messages/[some_auto_id]"
    }
    
    func sendPhotoMessage(photoData: Data) {
        
       
       // MARK: build a path using the user's ID and a timestamp
        let imagePath = "chat_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        // MARK: set content type to "image/jpeg" in firebase storage meta data
        let metadata = StorageMetadata()
       // metadata.contentType = "image/jpeg"
        // MARK: create a child node at imagePath with photoData and metdata
        storageRef!.child(imagePath).putData(photoData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("error uploading: \(error)")
                return
            }
            // MARK: use sendMessage to add imageURL to database
            self.sendMessage(data: [Constants.MessageFields.imageUrl: self.storageRef.child((metadata?.path)!).description])
        }
    }
    
    // MARK: Alert
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Scroll Messages
    
    func scrollToBottomMessage() {
        if messages.count == 0 { return }
        let bottomMessageIndex = IndexPath(row: messagesTable.numberOfRows(inSection: 0) - 1, section: 0)
        messagesTable.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func showLoginView(_ sender: AnyObject) {
        loginSession()
    }
    
    @IBAction func didTapAddPhoto(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
    @IBAction func didSendMessage(_ sender: UIButton) {
        // MARK: This function returns the text field and then erases its content
        let _ = textFieldShouldReturn(messageTextField)
        messageTextField.text = ""
    }
    
    @IBAction func dismissImageDisplay(_ sender: AnyObject) {
        // if touch detected when image is displayed
        if imageDisplay.alpha == 1.0 {
            UIView.animate(withDuration: 0.25) {
                self.backgroundBlur.effect = nil
                self.imageDisplay.alpha = 0.0
            }
            dismissImageRecognizer.isEnabled = false
            messageTextField.isEnabled = true
        }
    }
    
    @IBAction func tappedView(_ sender: AnyObject) {
        resignTextfield()
    }
}

// MARK: - FCViewController: UITableViewDelegate, UITableViewDataSource

extension FCViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeue cell
        let cell: UITableViewCell! = messagesTable.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        
        // MARK: unpack message from firebase data snapshot
        let messageSnapshot: DataSnapshot! = messages[indexPath.row]
        
        // MARK: fetching all the data contained in the snapshot
        let message = messageSnapshot.value as! [String:String]
        let name = message[Constants.MessageFields.name] ?? "[username]"
        // MARK: if photot message, then grab image and display it
        if let imageUrl = message[Constants.MessageFields.imageUrl] {
            cell!.textLabel?.text = "sent by: \(name)"
            // MARK: download and display image
            Storage.storage().reference(forURL: imageUrl).getData(maxSize: INT64_MAX) { (data, error) in
                guard error == nil else {
                    print("error downloading: \(error!)")
                    return
                }
                // MARK: display image
                let messageImage = UIImage.init(data: data!, scale: 50)
                // MARK: check if the cell is still on screen, if so, update cell image
                if cell == tableView.cellForRow(at: indexPath) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = messageImage
                        cell.setNeedsLayout()
                    }
                }
            }
        } else {
            // MARK: otherwise,update cell for regular message
        let text = message[Constants.MessageFields.text] ?? "[message]"
        // MARK: now we set the data that we fetched into our table view cell
        cell!.textLabel?.text = name + ": " + text
        cell!.imageView?.image = self.placeholderImage
    }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: skip if keyboard is shown
        guard !messageTextField.isFirstResponder else { return }
        
        // MARK: unpack mesage frome firebase data snapshot
        let messageSnapshot: DataSnapshot! = messages[(indexPath as NSIndexPath).row]
        let message = messageSnapshot.value as! [String:String]
        
        // MARK: if tapped row with image message, then display image
        if let imageUrl = message[Constants.MessageFields.imageUrl] {
            if let cachedImage = imageCache.object(forKey: imageUrl as NSString){
                showImageDisplay(cachedImage)
            } else {
                Storage.storage().reference(forURL: imageUrl).getData(maxSize: INT64_MAX) { (data, error) in
                    guard error == nil else {
                        print("Error downloading: \(error!)")
                        return
                    }
                    self.showImageDisplay(UIImage.init(data: data!)!)
                }
            }
        }
    }
    
    // MARK: Show Image Display
    
    func showImageDisplay(_ image: UIImage) {
        dismissImageRecognizer.isEnabled = true
        dismissKeyboardRecognizer.isEnabled = false
        messageTextField.isEnabled = false
        UIView.animate(withDuration: 0.25) {
            self.backgroundBlur.effect = UIBlurEffect(style: .light)
            self.imageDisplay.alpha = 1.0
            self.imageDisplay.image = image
        }
    }
    
    // MARK: Show Image Display
    
    func showImageDisplay(image: UIImage) {
        dismissImageRecognizer.isEnabled = true
        dismissKeyboardRecognizer.isEnabled = false
        messageTextField.isEnabled = false
        UIView.animate(withDuration: 0.25) {
            self.backgroundBlur.effect = UIBlurEffect(style: .light)
            self.imageDisplay.alpha = 1.0
            self.imageDisplay.image = image
        }
    }
}

// MARK: - FCViewController: UIImagePickerControllerDelegate

extension FCViewController: UIImagePickerControllerDelegate {
    
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        
        // MARK: constant to hold the information about the photo
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let photoData = photo.jpegData(compressionQuality: 0.8) {
            // MARK: call function to upload photo message
            sendPhotoMessage(photoData: photoData)
        }
        // MARK: Dismiss image picker controller
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Function when the user just cancels his request and doesn't actually pick an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - FCViewController: UITextFieldDelegate

extension FCViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // set the maximum length of the message
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= msglength.intValue
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // MARK: If the text field in question is NOT empty, the string contained in this text field is passed to a data dictionnary. This data is passed on to another function called sendMessage()
        if !textField.text!.isEmpty {
            let data = [Constants.MessageFields.text: textField.text! as String]
            sendMessage(data: data)
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            self.view.frame.origin.y -= self.keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            self.view.frame.origin.y += self.keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
        dismissKeyboardRecognizer.isEnabled = true
        scrollToBottomMessage()
    }
    
    func keyboardDidHide(_ notification: Notification) {
        dismissKeyboardRecognizer.isEnabled = false
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        return ((notification as NSNotification).userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
    }
    
    func resignTextfield() {
        if messageTextField.isFirstResponder {
            messageTextField.resignFirstResponder()
        }
    }
}

// MARK: - FCViewController (Notifications)

extension FCViewController {
    /*
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    */
    func subscribeToNotification(_ name: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


