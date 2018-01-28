//
//  SignUpController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/8/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ViewIcon: UIView!
    @IBOutlet weak var FieldName: UITextField!
    @IBOutlet weak var FieldEmail: UITextField!
    @IBOutlet weak var FieldPassword: UITextField!
    @IBOutlet weak var SwitchShowPassword: UISwitch!
    @IBOutlet weak var LabelError: UILabel!
    @IBOutlet weak var ButtonSignUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set textfield delegate to self
        FieldName.delegate = self
        FieldEmail.delegate = self
        FieldPassword.delegate = self
        
        // Style View
        
        /*
        FieldName.layer.cornerRadius = 2
        FieldEmail.layer.cornerRadius = 2
        FieldPassword.layer.cornerRadius = 2
        ButtonSignUp.layer.cornerRadius = 4
 */
    }
    
    override func viewDidLayoutSubviews() {
        ViewIcon.layer.cornerRadius = ViewIcon.frame.width/2
        FieldName.setBottomBorder()
        FieldEmail.setBottomBorder()
        FieldPassword.setBottomBorder()
        SwitchShowPassword.scale(x: 0.75, y: 0.75)
        self.view.addGradientBackground()
        
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Attempt Sign Up
    @IBAction func AttemptSignUp(_ sender: Any) {
        if FieldName.text == "" || FieldEmail.text == "" || FieldPassword.text == "" {
            // Show error message
            self.LabelError.text = "Please provide a valid name, email, and password"
            self.LabelError.isHidden = false
        } else {
            // Attempt login
            Auth.auth().createUser(withEmail: FieldEmail.text!, password: FieldPassword.text!) { (user, error) in
                
                if error == nil {
                    // Save name to user
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let changeRequest = user.createProfileChangeRequest()
                        
                        changeRequest.displayName = self.FieldName.text
                        changeRequest.commitChanges { error in
                            if let error = error {
                                // An error happened.
                                print(error.localizedDescription)
                            } else {
                                // Profile updated, add user to DB
                                UserManager.createUser(user)
                            }
                        }
                    }
                    
                    //Present Home Controller
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    // Sign up failed, display error message
                    self.LabelError.text = error?.localizedDescription
                    self.LabelError.isHidden = false
                }
            }
        }
    }
    
    //Show/Hide Password
    @IBAction func ShowPasswordSwitchToggled(_ sender: Any) {
        if SwitchShowPassword.isOn {
            FieldPassword.isSecureTextEntry = false
        } else {
            FieldPassword.isSecureTextEntry = true
        }
    }
    
    // Textfield Navigation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case FieldName:
            FieldEmail.becomeFirstResponder()
            break
        case FieldEmail:
            FieldPassword.becomeFirstResponder()
            break
        case FieldPassword:
            textField.resignFirstResponder()
            AttemptSignUp(self)
            break
        default:
            textField.resignFirstResponder()
            break
        }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Mark: - Rotation
    override var shouldAutorotate: Bool {
        return false
    }
}
