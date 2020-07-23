//
//  PasswordResetVC.swift
//  MoreThanBD
//
//  Created by Matt Witzerman on 7/23/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit

class PasswordResetVC: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let accountManager = FirebaseAuthManager()
        guard let email = emailField.text else{
            return
        }
        
        accountManager.resetPassword(email: email) {[weak self] (success) in
            if success{
                let alertController = UIAlertController(title: nil, message: "Success. Please check your email for instructions on how to reset password.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                
                //self!.present(alertController, animated: true, completion: nil)
                self!.goToLogin()
            }
            else{
                print("Error sending reset email")
            }
        }
    }
    
    func goToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: "loginVC") as! LogInVC
        
        //homeTabVarViewController.username="username"
        
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
}
