//
//  NewCommentsViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/10/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class CommentsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var CommentTextView: UITextView!
    @IBOutlet weak var PostButton: UIButton!
    
    public var postID: String!
    public var initialViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure Comment TextView
        CommentTextView.delegate = self
        
        PostManager.listenForComments(inPost: postID) { (comments) in
            let childView = self.childViewControllers.first as! CommentsTableViewController
            childView.comments.append(contentsOf: comments)
            childView.comments.sort(by: { (c1, c2) -> Bool in
                return c1.timestamp.compare(c2.timestamp) == ComparisonResult.orderedAscending
            })
            childView.tableView.reloadData()
        }
        
        // Show/Hide Keyboard Listeners
        NotificationCenter.default.addObserver(self, selector: #selector(NewUploadViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewUploadViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialViewHeight = view.frame.height
    }
    
    @IBAction func PostComment(_ sender: Any) {
        let comment = Comment()
        comment.userID = Auth.auth().currentUser!.uid
        comment.body = CommentTextView.text
        comment.timestamp = Date()
        
        PostManager.postComment(comment, onPostID: postID)
        
        CommentTextView.text = ""
        PostButton.isEnabled = false
        
        // Scroll to bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let childView = self.childViewControllers.first as! CommentsTableViewController
            childView.tableView.scrollToRow(at: IndexPath(row: childView.comments.count-1, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
        
    }
    
    // MARK: - TextView Delegate
    
    // Enable/Disable Submit button
    func textViewDidChange(_ textView: UITextView) {
        PostButton.isEnabled = CommentTextView.text.count > 0
        textView.returnKeyType = (CommentTextView.text.count > 0) ? UIReturnKeyType.yahoo : UIReturnKeyType.yahoo
    }
    
    // Submit comment
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            if text.count > 0 {
                PostComment(self)
            }
            
            CommentTextView.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Handle Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let currentFrame = self.view.frame
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height - 49
                }
            }
            //self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: currentFrame.width, height: initialViewHeight - (keyboardHeight + 49))
            
            // Move origin up instead of resizing. Seems to work more
            // consistently for some reason, but not necessarily the optimal choice
            //view.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let currentFrame = self.view.frame
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height + 49
            }
        }
        //self.view.frame = CGRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: currentFrame.width, height: initialViewHeight)
        
        // Move origin down instead of resizing. Seems to work more
        // consistently for some reason, but not necessarily the optimal choice
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        PostManager.stopListeningForComments()
    }

}
