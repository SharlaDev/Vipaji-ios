//
//  RankingViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/15/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RankingViewController: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var UserImageView: UIImageView!
    @IBOutlet weak var RankImageView: UIImageView!
    @IBOutlet weak var RegionImageView: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var RankLabel: UILabel!
    @IBOutlet weak var RegionLabel: UILabel!
    @IBOutlet weak var RankBackgroundView: UIView!
    @IBOutlet weak var RegionBackgroundView: UIView!
    
    override func viewDidLoad() {
        // Style tab bar
        settings.style.buttonBarBackgroundColor = UIColor(white: 1, alpha: 0)
        settings.style.buttonBarItemBackgroundColor = UIColor(white: 1, alpha: 0)
        settings.style.selectedBarBackgroundColor = .white
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarItemFont = .systemFont(ofSize: 20, weight: .medium)
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        super.viewDidLoad()
        
        // Load rankings
        /*
        UserManager.fetchTopRankedUsers { (userProfiles) in
            let ranksVC = self.childViewControllers.first as! RanksViewController
            ranksVC.containerController = self
            ranksVC.rankedUsers = userProfiles
            ranksVC.tableView.reloadData()
        }
 */
        
        // Style Nav Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style backgrounds views
        UserImageView.layer.cornerRadius = UserImageView.frame.width/2
        UserImageView.layer.borderWidth = 4
        UserImageView.layer.borderColor = UIColor.white.cgColor
        UserImageView.clipsToBounds = true
        
        RankBackgroundView.layer.cornerRadius = RankBackgroundView.frame.width/2
        RankBackgroundView.layer.borderWidth = 4
        RankBackgroundView.layer.borderColor = UIColor.white.cgColor
        
        RegionBackgroundView.layer.cornerRadius = RegionBackgroundView.frame.width/2
        RegionBackgroundView.layer.borderWidth = 4
        RegionBackgroundView.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Tab Bar Controller
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let globalVC = storyboard?.instantiateViewController(withIdentifier: "Rankings") as! RanksViewController
        globalVC.region = CompetingRegion.global
        
        let localVC = storyboard?.instantiateViewController(withIdentifier: "Rankings") as! RanksViewController
        localVC.region = CompetingRegion.local
        
        return [globalVC, localVC]
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
