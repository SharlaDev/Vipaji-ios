//
//  NewNewConversationController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/3/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewConversationCell: UITableViewCell {
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var UserImageView: UIImageView!
    
    //public var nameLabel = UILabel()
    //public var userImageView = UIImageView()
    
    override func awakeFromNib() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Style components
        //UserImageView.layer.cornerRadius = UserImageView.frame.width
    }
}

private struct User {
    var ID: String
    var name: String
    var photoURL: URL?
    var userImageView = UIImageView()
}

class NewConversationController: UITableViewController {
    
    //var userIDs = [String]()
    private var users = [User]()
    private var visibleUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SearchField.delegate = self
        
        // Load list of followed users by ID, get user info, and refresh
        UserManager.fetchFollowed { (userIDs) in
            for ID in userIDs {
                UserManager.userInfo(forUserID: ID, completion: { (userInfo) in
                    let userImageView = UIImageView()
                    if let url = userInfo?.photoDataURL {
                        userImageView.downloadedFrom(url: url)
                    } else {
                        userImageView.image = UIImage(named: "User Placeholder")
                    }
                    
                    let user = User(ID: ID, name: userInfo!.name, photoURL: userInfo!.photoDataURL, userImageView: userImageView)
                    self.users.append(user)
                    self.visibleUsers = self.users
                })
            }
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
        return visibleUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationCell", for: indexPath) as! NewConversationCell
        let user = visibleUsers[indexPath.row]
        
        cell.NameLabel.text = user.name
        cell.UserImageView = user.userImageView
        /*
        if user.userImageView == nil {
            if let url = user.photoURL {
                visibleUsers[indexPath.row].userImageView.downloadedFrom(url: url)
                users[users.index(where: { $0.ID == user.ID })!].userImageView.downloadedFrom(url: url)
                
                cell.UserImageView.downloadedFrom(url: url)
            } else {
                visibleUsers[indexPath.row].userImageView.image = UIImage(named: "User Placeholder")
                users[users.index(where: { $0.ID == user.ID })!].userImageView.image = UIImage(named: "User Placeholder")
                
                cell.UserImageView = visibleUsers[indexPath.row].userImageView
            }
        } else {
            cell.UserImageView = user.userImageView
        }
        //todo: set image with cache
 */
        
        /*
        DB.userInfo(forUserID: userID, completion: ({ (userInfo) in
            cell.NameLabel.text = userInfo?.name
            if let url = userInfo?.photoDataURL {
                let imageView = UIImageView()
                imageView.downloadedFrom(url: url, contentMode: UIViewContentMode.scaleAspectFit)
                cell.UserImageView = imageView
            } else {
                cell.UserImageView.image = UIImage(named: "User Placeholder")
            }
        }))
 */
        
        /*
        cell.NameLabel.text = userID
        UserManager.imageURL(forUserID: userID) { (imageURL) in
            if let url = imageURL {
                let imageView = UIImageView()
                imageView.downloadedFrom(url: url, contentMode: UIViewContentMode.scaleAspectFit)
                cell.UserImageView = imageView
            } else {
                cell.UserImageView.image = UIImage(named: "User Placeholder")
            }
        }
 */
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = visibleUsers[indexPath.row]
        
        // Check if conversation between these two users already exists
        var userIDs = [Auth.auth().currentUser!.uid, user.ID]
        userIDs = userIDs.sorted()
        
        
        let conv = Conversation()
        conv.ID = "\(userIDs[0]) - \(userIDs[1])"
        conv.userIDs = [Auth.auth().currentUser!.uid, user.ID]
        conv.messages = [Message]()
        conv.downloadedUserImageView = user.userImageView
        
        let conversationVC = storyboard?.instantiateViewController(withIdentifier: "Conversation") as! ConversationViewController
        conversationVC.conversation = conv
        conversationVC.isNewConversation = true
        
        //navigationController?.popViewController(animated: false)
        navigationController?.pushViewController(conversationVC, animated: true)
        
        // Remove New Conversation VC from stack
        /*
        for VC in navigationController!.viewControllers {
            if VC is NewConversationController {
                navigationController.pop
                
                VC.removeFromParentViewController()
            }
        }
 */
    }

    // MARK: - Search Field
    
    @IBAction func SearchTextEdited(_ sender: UITextField) {
        if let searchQuery = sender.text?.lowercased() {
            if searchQuery.count > 0 {
                visibleUsers = users.filter { $0.name.lowercased().hasPrefix(searchQuery) }
                tableView.reloadData()
            }
        }
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
