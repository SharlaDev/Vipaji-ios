//
//  DiscoverTabViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/21/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class DiscoverTabViewController: ButtonBarPagerTabStripViewController, UIGestureRecognizerDelegate {
    
    private var isTabBarVisible: Bool = true
    
    override func viewDidLoad() {
        
        self.containerView.isScrollEnabled = false
        
        // Style Tab Bar
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - Scrolling
    
    override func viewDidAppear(_ animated: Bool) {
        // Create gradient layer
        let lightBlue = UIColor(red:0.00, green:0.45, blue:1.00, alpha:1.0).cgColor
        let darkBlue = UIColor(red:0.00, green:0.24, blue:0.75, alpha:1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 48 + 30)
        gradientLayer.colors = [lightBlue, darkBlue]
        
 
        // Scrolling gestures
        let nextSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DiscoverTabViewController.showNext))
        nextSwipeRecognizer.direction = .up
        
        let prevSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DiscoverTabViewController.showPrev))
        prevSwipeRecognizer.direction = .down
        
        view.addGestureRecognizer(nextSwipeRecognizer)
        view.addGestureRecognizer(prevSwipeRecognizer)
        super.viewDidAppear(animated)
    }
    
    @objc func showNext() {
        let childVC = childViewControllers.first as! DiscoverViewController
        let tableView = childVC.tableView
        
        if isTabBarVisible {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (46 + 36), width: self.view.frame.width, height: self.view.frame.height + 46 + 36)
                
                if childVC.currentCell + 1 < childVC.posts.count {
                    childVC.currentCell += 1
                    tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
                }
            }, completion: { (completed) in
                    tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
                    childVC.updatePlaying()
            })
            
            isTabBarVisible = false
        } else {
            if childVC.currentCell + 1 < childVC.posts.count {
                childVC.currentCell += 1
                tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
            
                childVC.updatePlaying()
            }
        }
    }
    
    @objc func showPrev() {
        let childVC = childViewControllers.first as! DiscoverViewController
        let tableView = childVC.tableView
        
        if !isTabBarVisible {
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y + 46 + 36, width: self.view.frame.width, height: self.view.frame.height - (46 + 36))
                
                if childVC.currentCell > 0 {
                    childVC.currentCell -= 1
                    tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
                }
            }, completion: { (completed) in
                    tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
                    childVC.updatePlaying()
            })
            
            isTabBarVisible = true
        } else {
            if childVC.currentCell > 0 {
                childVC.currentCell -= 1
                tableView?.scrollToRow(at: IndexPath(row: 0, section: childVC.currentCell), at: .middle, animated: true)
                
                childVC.updatePlaying()
            }
        }
    }
    
    // Mark: - Tab Setup
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let discoverGlobalVC = storyboard!.instantiateViewController(withIdentifier: "DiscoverFeed") as! DiscoverViewController
        
        let discoverLocalVC = storyboard!.instantiateViewController(withIdentifier: "DiscoverFeed") as! DiscoverViewController
        discoverLocalVC.isLocal = true
        
        return [discoverGlobalVC, discoverLocalVC]
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
