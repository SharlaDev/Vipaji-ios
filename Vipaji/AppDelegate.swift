//
//  AppDelegate.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/8/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public var isRotationAllowed: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent;
        
        // Style Navigation Bar
        /*
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white;
        navigationBarAppearace.barTintColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0) //Off black
        
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
 */
        
        
        
        // Style Tab Bar
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.white //UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0) //Off black
        UITabBar.appearance().tintColor = UIColor(red:0.00, green:0.06, blue:0.55, alpha:1.0) //UIColor(red:0.00, green:0.00, blue:0.80, alpha:1.0) //UIColor.white
        //UITabBar.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Edmondsans-Bold", size: 10)!, NSForegroundColorAttributeName:UIColor.redColor()], forState: UIControlState.Normal)
        
        // Present RootTabController if user already logged in
        if Auth.auth().currentUser != nil {
            window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabController")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

