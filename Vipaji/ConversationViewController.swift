//
//  ConverstaionViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/6/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var HeaderUserImageView: UIImageView!
    @IBOutlet weak var HeaderNameLabel: UILabel!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var AuthorView: UIStackView!
    
    public var isNewConversation: Bool = false
    public var conversation: Conversation!
    
    private var conversationTableVC: ConversationTableViewController!
    private var initialViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessageTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        ConversationManager.enableListener(forConversation: conversation.ID) { (messages) in
            self.conversation.messages.insert(contentsOf: messages, at: 0)
            self.conversation.messages.sort(by: { (m1, m2) -> Bool in
                return m1.timestamp.compare(m2.timestamp) == ComparisonResult.orderedDescending
            })
            self.conversationTableVC.tableView.reloadData()
        }
        
        // Add tap gesture to load profile
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        AuthorView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set header
        HeaderUserImageView.image = conversation.downloadedUserImageView.image
        HeaderNameLabel.text = conversation.otherUserName
        
        // Style header
        HeaderView.addGradientBackground()
        HeaderUserImageView.layer.cornerRadius = HeaderUserImageView.frame.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initialViewHeight = self.view.frame.height
        
        conversationTableVC = childViewControllers.first as! ConversationTableViewController
        conversationTableVC.conversation = conversation
        conversationTableVC.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Send Message
    
    @IBAction func SendMessage(_ sender: UIButton?) {
        let message = Message()
        message.ID = NSUUID().uuidString
        message.message = MessageTextView.text
        message.timestamp = Date.init(timeIntervalSinceNow: 0)
        for ID in conversation.userIDs { //Programmed this way to facilitate potential move to multi user messaging
            if ID == Auth.auth().currentUser!.uid {
                message.senderID = ID
            } else {
                message.recipientID = ID
            }
        }
        
        ConversationManager.sendMessage(message, inConveration: conversation.ID, isNewConversation: isNewConversation)
        isNewConversation = false
        
        MessageTextView.text = ""
        SendButton.isEnabled = false
    }
    
    // MARK: - Message Textview
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            self.view.frame.size = CGSize(width: self.view.frame.size.width, height: initialViewHeight - keyboardHeight + 49)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size = CGSize(width: self.view.frame.size.width, height: initialViewHeight)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            SendMessage(nil)
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        SendButton.isEnabled = MessageTextView.text.count > 0
    }
    
    @objc func showProfile() {
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! NewProfileViewController
        profileVC.userID = conversation.userIDs.filter { $0 != Auth.auth().currentUser!.uid }[0]
        navigationController?.pushViewController(profileVC, animated: true)
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
