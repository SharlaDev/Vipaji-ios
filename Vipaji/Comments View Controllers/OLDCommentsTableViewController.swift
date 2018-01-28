//
//  CommentsTableViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/17/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class OLDCommentCell: UITableViewCell {
    @IBOutlet weak var LabelName: UILabel!
    @IBOutlet weak var LabelCommentInfo: UILabel!
    @IBOutlet weak var TextViewComment: UITextView!
    @IBOutlet weak var ImageAuthor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style user photo
        ImageAuthor.layer.cornerRadius = ImageAuthor.frame.width/2
        ImageAuthor.clipsToBounds = true
        
        // Style TextViewComment
        TextViewComment.textContainer.lineFragmentPadding = 0
        TextViewComment.textContainerInset = .zero
    }
}

class OLDCommentsTableViewController: UITableViewController {
    
    public var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // Set row height to auto
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    public func refresh() {
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! OLDCommentCell

        let comment = comments[indexPath.row]
        
        // Configure the cell
        cell.LabelName.text = "placeholder"
        cell.TextViewComment.text = comment.body
        cell.LabelCommentInfo.text = comment.timestamp.toString(dateFormat: "MMMM dd")
        if comment.downloadedUserImageView != nil {
            cell.ImageAuthor = comment.downloadedUserImageView
        } else {
            UserManager.imageURL(forUserID: comment.userID, result: { (photoURL) in
                if let url = photoURL {
                    self.comments[indexPath.row].downloadedUserImageView = UIImageView()
                    self.comments[indexPath.row].downloadedUserImageView?.downloadedFrom(url: url)
                    cell.ImageAuthor.downloadedFrom(url: url)
                } else {
                    cell.ImageAuthor.image = UIImage(named: "User Placeholder")
                }
            })
        }
        
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //DB.stopListeningForComments()
    }

}
