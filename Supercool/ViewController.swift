//
//  ViewController.swift
//  Supercool
//
//  Created by BoTingDing on 2018/4/9.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class ViewController: UIViewController, FUIAuthDelegate {

    //database
    var ref: DatabaseReference!
    
    var user: User!
    
    @IBAction func logout(_ sender: Any) {
//        do {
//            let authUI = FUIAuth.defaultAuthUI()
//
//            try authUI?.signOut()
//
//        } catch {
//            print("sth went wrong")
//        }
        
        
        ref = Database.database().reference()
        var article = ["article" : "life", "content": "is", "tag": "a shit"]
        
        ref?.child("User").child(user!.uid).childByAutoId().setValue(article)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let authUI = FUIAuth.defaultAuthUI()

        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
//        //create user
//        Auth.auth().createUser(withEmail: "123@123.123.123", password: "123456") { (user, error) in
//            // ...
//            if error == nil && user != nil {
//                print("sign up")
//                print("name = \(user?.displayName), email = \(user?.email)")
//
//            }else {
//                print("error creating user \(error?.localizedDescription)")
//            }
//        }
        
        //sign in user
        Auth.auth().signIn(withEmail: "123@123.123.123", password: "123456"){ (user, error) in
                        // ...
                        if error == nil && user != nil {
                            print("sign in")
                            print("name = \(user?.displayName), email = \(user?.email)")
                            self.user = user

                        }else {
                            print("error creating user \(error?.localizedDescription)")
                        }
                    }

        
        
        
        
       
      

    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        if error == nil {
            
            print("sign with \(user?.email)")
        }else {
            print("sign in with error \(error?.localizedDescription)")
        }
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func readArticle(_ sender: Any) {
        
        let userID = Auth.auth().currentUser?.uid
        ref = Database.database().reference()

        ref?.child("User").child(userID!).observe(.value, with: { (snapshot) in
            // Get user value
            if let users = snapshot.value as? NSDictionary {
            
                for (key, value) in users {
                    print(value)
                }
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}

struct Article {
    var title: String
    var content: String
    var tag: String
}

