//
//  RootTabViewController.swift
//  Vipaji
//
//  Created by Mickey on 1/29/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootTabViewController: UIViewController {

    @IBOutlet weak var ViewContainer: UIView!
    @IBOutlet var TabButtons: [UIButton]!
    var homeVC: UIViewController!
    var searchVC: UIViewController!
    var uploadVC: UIViewController!
    var rankingVC: UIViewController!
    var profileVC: UIViewController!
    
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        homeVC = storyboard.instantiateViewController(withIdentifier: "HomeRootViewController")
        searchVC = storyboard.instantiateViewController(withIdentifier: "SearchRootViewController")
        uploadVC = storyboard.instantiateViewController(withIdentifier: "UploadRootViewController")
        rankingVC = storyboard.instantiateViewController(withIdentifier: "RankingRootViewController")
        profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileRootViewController")
        
        for index in 0...4 {
            TabButtons[index].layer.cornerRadius = 22
        }
        viewControllers = [homeVC, searchVC, uploadVC, rankingVC, profileVC]
        TabButtons[selectedIndex].isSelected = true
        didPressTabs(TabButtons[selectedIndex])
    }

    @IBAction func didPressTabs(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        TabButtons[previousIndex].isSelected = false
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        sender.isSelected = true
        let vc = viewControllers[selectedIndex]
        addChildViewController(vc)
        
        vc.view.frame = ViewContainer.bounds
        ViewContainer.addSubview(vc.view)
        
        vc.didMove(toParentViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // todo: Attempt sign in with saved credentials
        } else {
            // Present sign up view
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUp")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed
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
