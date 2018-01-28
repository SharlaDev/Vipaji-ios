//
//  SignInViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/8/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var FieldEmail: UITextField!
    @IBOutlet weak var FieldPassword: UITextField!
    @IBOutlet weak var SwitchShowPassword: UISwitch!
    @IBOutlet weak var LabelError: UILabel!
    @IBOutlet weak var ButtonSignIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set textfield delegate to self
        FieldEmail.delegate = self
        FieldPassword.delegate = self
        
        // Style View
        FieldEmail.layer.cornerRadius = 2
        FieldPassword.layer.cornerRadius = 2
        ButtonSignIn.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addGradientBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Attempt sign in
    @IBAction func AttemptSignIn(_ sender: Any) {
        if FieldEmail.text == "" || FieldPassword.text == "" {
            LabelError.text = "Please enter a valid email and password"
            LabelError.isHidden = false
        } else {
            Auth.auth().signIn(withEmail: FieldEmail.text!, password: FieldPassword.text!) { (user, error) in
                if error == nil {
                    //Present Home Controller
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else { //Login failed
                    self.LabelError.text = error?.localizedDescription
                    self.LabelError.isHidden = false
                }
            }
        }
    }

    //Show/Hide Password
    @IBAction func ShowPasswordSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            FieldPassword.isSecureTextEntry = false
        } else {
            FieldPassword.isSecureTextEntry = true
        }
    }
    
    // Textfield Navigation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField
        {
        case FieldEmail:
            FieldPassword.becomeFirstResponder()
            break
        case FieldPassword:
            textField.resignFirstResponder()
            AttemptSignIn(self)
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
