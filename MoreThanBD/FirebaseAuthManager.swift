//
//  FirebaseAuthManager.swift
//  MoreThanBD
//
//  Created by Matt Witzerman on 7/22/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import FirebaseAuth
import UIKit

class FirebaseAuthManager {
    
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user{
                print(user)
                completionBlock(true)
            }
            else{
                if let err = error{
                    print(err)
                }
                completionBlock(false)
            }
        }
    }
    
    func signIn(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                completionBlock(false)
            }
            else{
                completionBlock(true)
            }
        }
    }
    
    func signOut() -> Bool{
        var success: Bool = true
        
        do {
            try Auth.auth().signOut()
        }
        catch{
            print("There was an error")
            success = false
        }
        
        return success
    }
    
    func resetPassword(email: String, completionBlock: @escaping (_ success: Bool) -> Void ) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error, let _ = AuthErrorCode(rawValue: error._code){
                completionBlock(false)
            }
            else{
                completionBlock(true)
            }
        }
    }
}
