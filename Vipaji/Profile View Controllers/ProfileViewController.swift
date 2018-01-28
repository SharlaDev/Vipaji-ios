//
//  ProfileController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/8/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var LabelName: UILabel!
    @IBOutlet weak var LabelPostsCount: UILabel!
    @IBOutlet weak var LabelFansCount: UILabel!
    @IBOutlet weak var TextViewBio: UITextView!
    @IBOutlet weak var ImageUser: UIImageView!
    @IBOutlet weak var ButtonAction: UIButton!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var AchievementsBackgroundView: UIView!
    
    let imagePicker = UIImagePickerController()
    
    public var isOwnProfile: Bool = true
    public var userID: String?
    public var userProfile: UserProfile! // = UserProfile()
    
    private var isBeingEdited: Bool = false
    private var dimView: UIView!
    private var exitView: UIView!
    private var achievementsViewController: ProfileAchievementsViewController!
    private var postsViewController: ProfilePostsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        achievementsViewController = self.childViewControllers[0] as! ProfileAchievementsViewController
        postsViewController = self.childViewControllers[1] as! ProfilePostsViewController
        
        // If no user provided, use user currently logged in
        if userID == nil {
            userID = Auth.auth().currentUser!.uid
        } else {
            isOwnProfile = false
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
        
        // Begin loading user posts
        postsViewController.userID = userID!
        postsViewController.loadPosts()
        
        // Get user info and set views
        UserManager.userInfo(forUserID: userID!, completion: { userInfo in
            self.userProfile = userInfo!
            
            // Set user name and bio
            self.LabelName.text = self.userProfile.name
            self.TextViewBio.text = self.userProfile.bio
            
            // Set user image if available
            if let photoURL: URL = self.userProfile.photoDataURL {
                self.ImageUser.downloadedFrom(url: photoURL)
            } else {
                self.ImageUser.image = UIImage(named: "User Placeholder")
            }
            
            self.LabelPostsCount.text = String(self.userProfile.postCount)
            self.LabelFansCount.text = String(self.userProfile.fanCount)
        })
        
        // Style profile image
        ImageUser.layer.borderWidth = 4
        ImageUser.layer.borderColor = UIColor.white.cgColor
        ImageUser.layer.cornerRadius = ImageUser.frame.width/2
        ImageUser.clipsToBounds = true
        
        // Configure action button
        ButtonAction.layer.cornerRadius = 4;
        //ButtonAction.layer.borderColor = UIColor.white.cgColor
        //ButtonAction.layer.borderWidth = 2
        
        if !isOwnProfile {
            ButtonAction.setTitle("Follow", for: .normal)
        } else {
            let signOutButton = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(ProfileViewController.SignOut))
            self.navigationItem.leftBarButtonItem = signOutButton
        }
        
        // Add tap gesture recognizer to profile image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageClicked))
        ImageUser.addGestureRecognizer(tapGestureRecognizer)
        
        // Configure image picker
        imagePicker.delegate = self
        
        HeaderView.addGradientBackground()
        
        // Style nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // Update follow/unfollow
        UserManager.isFollowing(userWithID: userID!) { (isFollowing) in
            if isFollowing {
                self.ButtonAction.setTitle("Unfollow", for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HeaderView.addGradientBackground()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = AchievementsBackgroundView.bounds
        gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.darkGray.cgColor]
        gradientLayer.locations = [0.0, 0.5, 0.95, 1.0]
        //AchievementsBackgroundView.layer.addSublayer(gradientLayer)
        
        //AchievementsBackgroundView.addGradientBackground()
        //testView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ButtonActionClicked(_ sender: UIButton) {
        if !isOwnProfile {
            UserManager.isFollowing(userWithID: userID!, finished: { (isFollowing) in
                if !isFollowing {
                    UserManager.follow(userWithID: self.userID!)
                    self.ButtonAction.setTitle("Unfollow", for: .normal)
                    
                    self.userProfile.fanCount += 1
                    self.LabelFansCount.text = String(self.userProfile.fanCount)
                } else {
                    UserManager.unfollow(userWithID: self.userID!)
                    self.ButtonAction.setTitle("Follow", for: .normal)
                    
                    self.userProfile.fanCount -= 1
                    self.LabelFansCount.text = String(self.userProfile.fanCount)
                }
            })
            
        } else {
            if isBeingEdited {
                // Disable editing
                ButtonAction.setTitle("Edit Profile", for: .normal)
                TextViewBio.isEditable = false
                
                // Save edits to DB
                userProfile.bio = TextViewBio.text
                UserManager.updateUserInfo(userID: userID!, userInfo: userProfile)
                
                // Disable editing
                isBeingEdited = false
                TextViewBio.textColor = UIColor.white
                
            } else {
                // Enable editing
                ButtonAction.setTitle("Save Edits", for: .normal)
                isBeingEdited = true
                
                // Enable editing of bio
                TextViewBio.isEditable = true
                TextViewBio.textColor = UIColor.lightGray
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let defaultBio = "I'm either a little shy or a little forgetful - I haven't written my bio!"
        if textView.text == defaultBio {
            textView.text = ""
        }
    }
    
    @objc public func profileImageClicked() {
        if !isBeingEdited {
            expandProfileImage()
        } else {
            showNewPictureOptions()
        }
    }
    
    public func expandProfileImage() {
        // Create background dim view
        dimView = UIView(frame: UIScreen.main.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.addSubview(dimView)
        
        // Move image to top
        self.ImageUser.layer.zPosition = 1;
        
        UIView.animate(withDuration: 0.4, animations: {
            // Dim background
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            
            // Calculate new frame
            let width = UIScreen.main.bounds.width - (16 + 16)
            let yPos = (self.view.bounds.height - (8 + 8))/2 - width/2 - 49/2 // Center image vertically. 49 is standard tab bar height
            
            // Set new image frame
            self.ImageUser.frame = CGRect(x: 0, y: yPos, width: width, height: width)
        })
        
        // Create fullscreen exit view
        exitView = UIView(frame: UIScreen.main.bounds)
        view.addSubview(exitView)
        
        // Add tap gesture recognizer
        let exitTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitFullScreenImageView))
        exitView.addGestureRecognizer(exitTapGestureRecognizer)
    }
    
    @objc public func exitFullScreenImageView() {
        UIView.animate(withDuration: 0.4, animations: {
            // Remove dim background
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            // Reset image frame
            self.ImageUser.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }, completion: { (finished: Bool ) in
            self.dimView.removeFromSuperview()
        })
        
        // Remove exitView
        exitView.removeFromSuperview()
    }
    
    public func showNewPictureOptions() {
        // Create the AlertController
        let actionSheetController = UIAlertController(title: "Change Profile Image", message: "Where would you like to choose from?", preferredStyle: .actionSheet)
        
        // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            // Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        // Create and add first option action
        let takePictureAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(takePictureAction)
        
        // Create and add a second option action
        let choosePictureAction = UIAlertAction(title: "Photo Library", style: .default) { action -> Void in
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        
        // Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Logout
    @objc func SignOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Failed to sign out")
        }
        
        let SignInVC = storyboard!.instantiateViewController(withIdentifier: "SignIn")
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = SignInVC
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            ImageUser.image = pickedImage
            
            // Get image data of square cropped image
            var data = NSData()
            data = UIImageJPEGRepresentation(pickedImage.crop(to: CGSize(width: 512, height: 512)), 0.8)! as NSData
            
            userProfile.photoData = data as Data
            
            //userProfile.photoURL = (info[UIImagePickerControllerReferenceURL] as! NSURL) as! URL //todo remove
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
