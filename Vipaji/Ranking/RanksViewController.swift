//
//  RanksViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/15/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RankCell: UITableViewCell {
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var RankLabel: UILabel!
    @IBOutlet weak var RankChangeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UserImageView.layer.cornerRadius = UserImageView.frame.width/2
        UserImageView.layer.borderWidth = 4
        UserImageView.layer.borderColor = UIColor.white.cgColor
        UserImageView.clipsToBounds = true
    }
}

enum CompetingRegion: String {
    case global = "Global"
    case local = "Local"
}

struct Ranking {
    public var userID: String!
    public var userName: String?
    public var downloadedUserImageView: UIImageView?
}

class RanksViewController: UITableViewController, IndicatorInfoProvider {

    public var rankings: [Ranking]?
    
    public var region: CompetingRegion!
    public var containerController: RankingViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserManager.rankedUsers { (userIDs) in
            self.rankings = [Ranking]()
            
            for userID in userIDs {
                var ranking = Ranking()
                ranking.userID = userID
                
                self.rankings?.append(ranking)
            }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: region.rawValue)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankings?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath) as! RankCell
        let ranking = rankings![indexPath.row]
        
        // Set rank
        cell.RankLabel.text = "\(indexPath.row + 1)"
        
        // Set name label
        if ranking.userName != nil {
            cell.NameLabel.text = ranking.userName
        } else {
            let index = indexPath.row
            UserManager.name(forID: ranking.userID) { (name) in
                cell.NameLabel.text = name
                self.rankings![index].userName = name
            }
        }
        
        // Set user image
        if ranking.downloadedUserImageView != nil {
            cell.UserImageView.image = ranking.downloadedUserImageView!.image
        } else {
            let index = indexPath.row
            UserManager.imageURL(forUserID: ranking.userID, result: { (photoURL) in
                if let url = photoURL {
                    cell.UserImageView.downloadedFrom(url: url)
                    self.rankings![index].downloadedUserImageView = UIImageView()
                    self.rankings![index].downloadedUserImageView!.downloadedFrom(url: url)
                } else {
                    cell.UserImageView.image = UIImage(named: "User Placeholder")
                    self.rankings![index].downloadedUserImageView = UIImageView()
                    self.rankings![index].downloadedUserImageView!.image = UIImage(named: "User Placeholder")
                }
            })
        }
        
        // Populate cells if info is loaded
        /*
        if rankedUsers != nil {
            let profile = rankedUsers![indexPath.row]
            
            cell.UserImageView.downloadedFrom(url: profile.photoDataURL!)
            cell.NameLabel.text = profile.name
            //todo: set username
            //todo: set rank change
        }
        
        cell.RankLabel.text = String(indexPath.row + 1)
 */

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userID = rankings![indexPath.row].userID
        
        let userProfileVC = parent?.storyboard?.instantiateViewController(withIdentifier: "Profile") as! NewProfileViewController
        userProfileVC.userID = userID
        parent?.navigationController?.pushViewController(userProfileVC, animated: true)
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
