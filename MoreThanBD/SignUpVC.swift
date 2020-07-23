//
//  SignUpVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailWarningLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapSignUpButton(_ sender: Any) {
        let signUpManager = FirebaseAuthManager()
        let isWustlEmail = validateEmail()
        
        if !isWustlEmail{
            emailWarningLabel.isHidden = false
            return
        }
        else{
            emailWarningLabel.isHidden = true
        }
        
        
        if let email = emailField.text, let password = passwordField.text {
            signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                guard let `self` = self else {return}
                var message: String = ""
                if(success) {
                    message = "User was successfully created"
                    self.goToHomeScreen()
                }
                else{
                    message = "There was an error"
                }
                
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                //self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func goToHomeScreen(){
        //after validation,call this function to make the Explore Page the rootViewController
        let homeTabVarViewController=storyboard?.instantiateViewController(identifier: "Home") as! myTabController
        
        //homeTabVarViewController.username="username"
        
        view.window?.rootViewController=homeTabVarViewController
        view.window?.makeKeyAndVisible()
    }
    
    func validateEmail() -> Bool {
        guard let email = emailField.text else{
            return false
        }
        
        let wustlRegex = "[A-Z0-9a-z._%+-]+@wustl.edu"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", wustlRegex)
        return emailPred.evaluate(with: email)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
