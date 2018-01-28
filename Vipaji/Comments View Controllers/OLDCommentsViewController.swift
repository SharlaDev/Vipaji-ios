//
//  CommentsViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/17/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class OLDCommentsViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var TextViewComment: UITextView!

    public var post: Post!
    public var postID: String = ""
    //public var commentcoll: [Comment]!
    private var containerVC: OLDCommentsTableViewController!
    private var initialViewHeight: CGFloat!
    
    //let commentPlaceholder = "Leave a comment..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set containerVC
        //containerVC = childViewControllers.last as! CommentsTableViewController
        
        // Move view up/down when keyboard appears/disappears
        NotificationCenter.default.addObserver(self, selector: #selector(OLDCommentsViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OLDCommentsViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Load comments
        /*
        DB.listenForComments(forPost: postID, completion: { (comments) in
            // todo: remove activity indicator
            
            // Set and present comment feed
            self.containerVC.comments = [Comment]()
            self.containerVC.comments = comments!
            self.containerVC.refresh()
            
        })
 */
        //self.containerVC.comments = [Comment]()
        //self.containerVC.refresh()
        
        
        // Configure TextView
        TextViewComment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialViewHeight = view.frame.height
    }
    
    @IBAction func PostCommentButtonClicked(_ sender: UIButton) {
        //if !((TextViewComment.text?.isEmpty)!) {
            
            // Create comment
            let comment = Comment()
            
            //todo: Show activity indicator
                
            // Set comment info
            comment.userID = Auth.auth().currentUser!.uid
            comment.timestamp = Date.init(timeIntervalSinceNow: 0)
            comment.body = self.TextViewComment.text
            
            PostManager.postComment(comment, onPostID: postID)
            
            // Add to comments and refresh view
            self.containerVC.comments.append(comment)
            self.containerVC.refresh()
            
            // Reset post comment view
            self.TextViewComment.text = ""
            //self.TextViewComment.resignFirstResponder()
        //}
    }
    
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == commentPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
 */
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: initialViewHeight - keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: initialViewHeight)
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
