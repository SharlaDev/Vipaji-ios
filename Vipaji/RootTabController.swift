//
//  MainTabController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/9/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootTabController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // todo: Attempt sign in with saved credentials
            /*
            Auth.auth().signIn(with: Auth.auth().currentUser.au, completion: <#T##AuthResultCallback?##AuthResultCallback?##(User?, Error?) -> Void#>) signIn(withEmail: Auth.auth().currentUser?.email, password: FieldPassword.text!) { (user, error) in
                // If sign in failed present sign up view
                if error != nil {,
                    self.LabelError.text = error?.localizedDescription
                    self.LabelError.isHidden = false
                }
            }
        */
        } else {
            // Present sign up view
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUp")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
