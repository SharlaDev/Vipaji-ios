//
//  MessagesViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/2/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessageViewCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var PreviewLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var UserImageView: UIImageView!
    
    override func awakeFromNib() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Style components
        UserImageView.layer.cornerRadius = UserImageView.frame.width/2
    }
}

class MessagesViewController: UITableViewController {

    private let userID = Auth.auth().currentUser!.uid
    private var conversations: [Conversation] = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        ConversationManager.fetchConversations(forUser: Auth.auth().currentUser!.uid) { (conversations) in
            self.conversations = conversations
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! MessageViewCell

        let conversation = conversations[indexPath.row]
        let otherUserID = conversation.userIDs.filter { $0 != userID }[0]
        
        // Set user name
        if let name = conversation.otherUserName {
            cell.NameLabel.text = name
        } else {
            UserManager.name(forID: otherUserID) { (name) in
                self.conversations[indexPath.row].otherUserName = name
                cell.NameLabel.text = name
            }
        }
        
        // Set user image
        if conversation.downloadedUserImageView != nil {
            cell.UserImageView = conversation.downloadedUserImageView
        } else {
            UserManager.imageURL(forUserID: otherUserID, result: { (photoURL) in
                if let url = photoURL {
                    self.conversations[indexPath.row].downloadedUserImageView = UIImageView()
                    self.conversations[indexPath.row].downloadedUserImageView?.downloadedFrom(url: url)
                    cell.UserImageView.downloadedFrom(url: url)
                } else {
                    let defaultImageView = UIImageView()
                    defaultImageView.image = UIImage(named: "User Placeholder")
                    
                    self.conversations[indexPath.row].downloadedUserImageView = defaultImageView
                    cell.UserImageView = defaultImageView
                }
            })
        }
        
        cell.PreviewLabel.text = conversation.messages.first!.message
        cell.DateLabel.text = conversation.messages.first!.timestamp.toString(dateFormat: "MMM dd")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        conversation.messages = [Message]() //clear single message
        
        let conversationVC = storyboard?.instantiateViewController(withIdentifier: "Conversation") as! ConversationViewController
        conversationVC.conversation = conversation
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
