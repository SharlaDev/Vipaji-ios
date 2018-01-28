//
//  NewCommentsTableViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/10/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var CommentTextView: UITextView!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var UserImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure Comment TextView
        CommentTextView.textContainer.lineFragmentPadding = 0
        CommentTextView.textContainerInset = .zero
        
        // Style User ImageView
        UserImageView.layer.cornerRadius = UserImageView.frame.width/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        UserImageView.image = nil
        
        super.prepareForReuse()
    }
}

class CommentsTableViewController: UITableViewController {

    public var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Automatic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
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
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        
        // Set name label
        if comment.userName != nil {
            cell.NameLabel.text = comment.userName
        } else {
            let index = indexPath.row
            UserManager.name(forID: comment.userID) { (name) in
                cell.NameLabel.text = name
                self.comments[index].userName = name
            }
        }
        
        // Set user image
        if comment.downloadedUserImageView != nil {
            cell.UserImageView.image = comment.downloadedUserImageView!.image
        } else {
            let index = indexPath.row
            UserManager.imageURL(forUserID: comment.userID, result: { (photoURL) in
                if let url = photoURL {
                    cell.UserImageView.downloadedFrom(url: url)
                    self.comments[index].downloadedUserImageView = UIImageView()
                    self.comments[index].downloadedUserImageView!.downloadedFrom(url: url)
                } else {
                    cell.UserImageView.image = UIImage(named: "User Placeholder")
                    self.comments[index].downloadedUserImageView = UIImageView()
                    self.comments[index].downloadedUserImageView!.image = UIImage(named: "User Placeholder")
                }
            })
        }
        
        // Set remaining comment info
        cell.CommentTextView.text = comment.body
        cell.DateLabel.text = comment.timestamp.toString(dateFormat: "MMMM dd")
        
        return cell
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
