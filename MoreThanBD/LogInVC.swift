//
//  LogInVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logIn_btn: UIButton!
    @IBOutlet weak var forgetPassword_btn: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailField.delegate = self
        passwordField.delegate = self
        setStyle()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func setStyle(){
        logIn_btn.layer.cornerRadius=15;
        logIn_btn.layer.backgroundColor=UIColor.systemGray6.cgColor
        
        forgetPassword_btn.layer.cornerRadius=15;
        forgetPassword_btn.layer.backgroundColor=UIColor.systemGray6.cgColor
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        let loginManager = FirebaseAuthManager()
        
        guard let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        loginManager.signIn(email: email, password: password) {[weak self] (success, user) in
            guard let `self` = self else {return}
            var message: String = ""
            if(success){
                message = "User successfully logged in"
                self.goToHomeScreen()
            }
            else{
                message = "There was an error"
            }
            
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func goToHomeScreen(){
        //after validation,call this function to make the Explore Page the rootViewController
        let homeTabVarViewController=storyboard?.instantiateViewController(identifier: "explore") as! ViewController
        
        let navVC = UINavigationController(rootViewController: homeTabVarViewController)
        
        //homeTabVarViewController.username="username"
        
        view.window?.rootViewController=navVC
        view.window?.makeKeyAndVisible()
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
