//
//  ConversationController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/5/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var MessageView: UITextView!
    
    public var isSender: Bool!
    
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        MessageView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        leftConstraint = NSLayoutConstraint(item: MessageView, attribute: .leading, relatedBy: .equal, toItem: ContentView, attribute: .leading, multiplier: 1, constant: 8)
        rightConstraint = NSLayoutConstraint(item: ContentView, attribute: .trailing, relatedBy: .equal, toItem: MessageView, attribute: .trailing, multiplier: 1, constant: 8)
        
        if isSender {
            MessageView.backgroundColor = UIColor.blue
            self.addConstraint(rightConstraint)
        } else {
            MessageView.backgroundColor = UIColor.green
            self.addConstraint(leftConstraint)
        }
    }
    
    override func prepareForReuse() {
        self.removeConstraint(rightConstraint)
        self.removeConstraint(leftConstraint)
        
        super.prepareForReuse()
    }
}

class ConversationTableViewController: UITableViewController {

    public var conversation: Conversation?
    
    private let currentUserID: String = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1);
        
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
        return (conversation != nil) ? conversation!.messages.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? ConversationCell
        cell!.transform = CGAffineTransform(scaleX: 1, y: -1); //flip cell
        
        let message = conversation!.messages[indexPath.row]
        
        cell!.MessageView.text = message.message
        cell!.isSender = (message.senderID == currentUserID) ? true : false
        
        return cell!
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