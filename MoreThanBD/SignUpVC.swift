//
//  SignUpVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
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
        
        
        if let email = emailField.text, let password = passwordField.text, let name = nameField.text {
            signUpManager.createUser(email: email, password: password) {[weak self] (success, user) in
                guard let `self` = self else {return}
                var message: String = ""
                if(success) {
                    message = "User was successfully created"
                    self.addUserToDB(name: name, user: user)
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
    
    func addUserToDB(name: String, user: User?) {
        guard let userId = user?.uid else {
            return
        }
        let userData = [
            "name": name,
            "id": userId
        ]
        Firestore.firestore().collection("users").document(userId).setData(userData) { (error) in
            if error == nil {
                AppData.userName = name
                self.goToHomeScreen()
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
}
