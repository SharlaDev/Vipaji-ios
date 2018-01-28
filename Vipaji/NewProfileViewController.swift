//
//  NewProfileViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/21/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewProfileViewController: UIViewController {

    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var BioTextView: UITextView!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var PostCountLabel: UILabel!
    @IBOutlet weak var FanCountLabel: UILabel!
    @IBOutlet weak var RankContainerView: UIView!
    
    public var userID: String?
    
    private var isOwnProfile: Bool = true
    private var isBeingEdited: Bool = false
    private var userProfile: UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If no ID is provided, use currently logged in user.
        if userID == nil {
            userID = Auth.auth().currentUser!.uid
        } else {
            isOwnProfile = false
        }
        
        if !isOwnProfile {
            // Configure Action Button
            UserManager.isFollowing(userWithID: userID!) { (isFollowing) in
                let buttonText = (isFollowing) ? "Unfollow" : "Follow"
                self.ActionButton.setTitle(buttonText, for: .normal)
            }

            // Remove sign out button
            self.navigationItem.leftBarButtonItem = nil
            
        } else {
            
        }
        
        // Load user information and configure view components.
        UserManager.userInfo(forUserID: userID!, completion: { userInfo in
            self.userProfile = userInfo!
            
            // Set user name and bio
            self.NameLabel.text = self.userProfile.name
            self.BioTextView.text = self.userProfile.bio
            
            // Set user image if available
            if let photoURL: URL = self.userProfile.photoDataURL {
                self.UserImageView.downloadedFrom(url: photoURL)
            } else {
                self.UserImageView.image = UIImage(named: "User Placeholder")
            }
            
            self.PostCountLabel.text = String(self.userProfile.postCount)
            self.FanCountLabel.text = String(self.userProfile.fanCount)
        })
        
        // Begin loading user posts
        let postsViewController = self.childViewControllers[0] as! ProfilePostsViewController
        postsViewController.userID = userID!
        postsViewController.loadPosts()
        
        // Tap Gestures ----------
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageClicked))
        UserImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Style ----------
        // Style Nav Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // Style User Image
        UserImageView.layer.cornerRadius = UserImageView.frame.width/2
        //UserImageView.layer.borderWidth = 4
        //UserImageView.layer.borderColor = UIColor.black.cgColor
        
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.UserImageView.frame.size)
        gradient.colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(rect: self.UserImageView.bounds).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.UserImageView.layer.addSublayer(gradient)
        
        // Style Bio TextView
        BioTextView.textContainerInset = UIEdgeInsets.zero
        BioTextView.textContainer.lineFragmentPadding = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Logic Controllers
    
    @objc public func profileImageClicked() {
        if !isBeingEdited {
            expandProfileImage()
        } else {
            //showNewPictureOptions()
        }
    }
    
    // MARK: - View Profile Image
    
    public func expandProfileImage() {
        // Create background dim view
        let dimView = UIView(frame: UIScreen.main.bounds)
        dimView.tag = 37
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
        //view.insertSubview(dimView, at: 4)
        view.addSubview(dimView)
        
        // Move image to top
        self.UserImageView.layer.zPosition = 1;
        //self.view.bringSubview(toFront: UserImageView)
        //UIApplication.shared.keyWindow!.bringSubview(toFront: UserImageView)
        
        UIView.animate(withDuration: 0.4, animations: {
            // Dim background
            dimView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            
            // Calculate new frame
            let width = UIScreen.main.bounds.width - (16 + 16)
            let yPos = (self.view.bounds.height - (8 + 8))/2 - width/2 - 49/2 // Center image vertically. 49 is standard tab bar height
            
            // Set new image frame
            self.UserImageView.frame = CGRect(x: 16, y: yPos, width: width, height: width)
        })
        
        // Create fullscreen exit view
        let exitView = UIView(frame: UIScreen.main.bounds)
        exitView.tag = 39
        view.addSubview(exitView)
        
        // Add tap gesture recognizer
        let exitTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(exitFullScreenImageView))
        exitView.addGestureRecognizer(exitTapGestureRecognizer)
    }
    
    @objc public func exitFullScreenImageView() {
        let dimView = self.view.viewWithTag(37)
        let exitView = self.view.viewWithTag(39)
        
        UIView.animate(withDuration: 0.4, animations: {
            // Remove dim background
            dimView?.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            // Reset image frame
            self.UserImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }, completion: { (finished: Bool ) in
            dimView?.removeFromSuperview()
        })
        
        // Remove exitView
        exitView?.removeFromSuperview()
    }
    
    
    
    
    @IBAction func SignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Failed to sign out")
        }
        
        let SignInVC = storyboard!.instantiateViewController(withIdentifier: "SignIn")
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = SignInVC
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
