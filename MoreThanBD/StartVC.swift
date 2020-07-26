//
//  StartVC.swift
//  MoreThanBD
//
//  Created by 马晓雯 on 7/18/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StartVC: UIViewController {

    @IBOutlet weak var signUp_btn: UIButton!
    @IBOutlet weak var logIn_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        authenticateAndConfigureWindow()
    }

    func authenticateAndConfigureWindow() {
        if Auth.auth().currentUser != nil{
            getUserName()
            goToHomeScreen()
        }
    }
    
    func getUserName() {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).getDocument { (snapshot, error) in
                let userObj = snapshot?.data() ?? [:]
                let name = userObj["name"] as? String
                AppData.userName = name
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
