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

class ViewController: UIViewController, FUIAuthDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var acceptFriendlist: UITableView!
    
    @IBOutlet weak var searchedTag: UITextField!
    var friend:[String] = []
    var acceptfriend:[String] = []
    var useremail:[String: String] = [:]
    var postRefHandle: DatabaseHandle!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.friendlist {
            
            return friend.count
        }else {
            return acceptfriend.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell;
        if tableView == self.friendlist {
        cell.email.text =  self.useremail[friend[indexPath.row]]
        
        return cell
        }else {
            
            cell.email.text =  self.useremail[acceptfriend[indexPath.row]]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.friendlist {
            self.displayShareSheet(indexPath)
            
        }else if tableView == self.acceptFriendlist {
//            print(acceptfriend[indexPath.row])
            
            
            ref = Database.database().reference()
            
            postRefHandle = ref?.child("Articles").observe(.value, with: { (snapshot) in
                // Get user value
                if let users = snapshot.value as? NSDictionary {
                    
                    for (key, value) in users {
                        if let vv = value as? NSDictionary{
                            if vv["author"] as? String == self.acceptfriend[indexPath.row] {
                                print(value)
                            }
                        }
                    }
                }
            })
                
            
            
        }
    }
    
    
    @IBOutlet weak var endtime: UITextField!
    @IBOutlet weak var starttime: UITextField!
    @IBOutlet weak var friendlist: UITableView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var tag: UITextField!
    @IBOutlet weak var content: UITextField!
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
        ref?.child("Articles").removeAllObservers()
        
        ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        let article = ["author": userID ?? "", "title" : titleLabel.text!, "content": content.text!, "tag": tag.text!, "createdtime": Int(NSDate().timeIntervalSince1970 * 1000) ] as [String : Any]
        
        ref?.child("Articles").childByAutoId().setValue(article)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       friendlist.delegate = self
        friendlist.dataSource = self
        acceptFriendlist.delegate = self
        acceptFriendlist.dataSource = self
        
        //xib的名稱
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        //註冊，forCellReuseIdentifier是你的TableView裡面設定的Cell名稱
        friendlist.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        
        acceptFriendlist.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        
        
        let authUI = FUIAuth.defaultAuthUI()

        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        
        ref = Database.database().reference()
//        let email = "7788@78.78"
//        let pwd = "787878"

//        let email = "123@123.123.123"
//        let pwd = "123456"
//        let email = "456@123.123.123"
//        let pwd = "123456"
//        let email = "9727@95.27"
//                let pwd = "123456"
//        let email = "5566@56.56"
//               let pwd = "787878"
        
        let email = "luke05@gmail.com"
        let pwd = "787878"
        

//
        
//        //create user
//        Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in
//            // ...
//            if error == nil && user != nil {
//
//                self.ref.child("User").child(user!.uid).child("email").setValue(user!.email)
//
//                print("sign up")
//                print("name = \(user?.displayName), email = \(user?.email)")
//
//            }else {
//                print("error creating user \(error?.localizedDescription)")
//            }
//        }
        
        //sign in user
        Auth.auth().signIn(withEmail: email, password: pwd){ [weak self] (user, error) in
                        // ...
                        if error == nil && user != nil {
                            print("sign in")
                        self?.ref.child("User").child(user!.uid).child("email").setValue(user!.email)

                            
                            
                            self?.user = user
                            
                            //取的user email
                            self?.ref.child("User").observe(.value, with: { snapshot in
                                if let user = snapshot.value as? NSDictionary {
                                    for (k, v) in user {
                                        let vv = v as! NSDictionary
                                        for (x, y) in vv {
                                        let kk = k as! String
                                            if x as! String == "email" {
                                                
                                                self?.useremail[kk] = y as! String
                                            }
                                        }
                                    }
                                }
                                
                                
                            })
                            
                            self?.ref.child("Friend").child(user!.uid).observe(.value, with: { snapshot in
                                var temp = [String]()
                                var tempadd = [String]()
                                if let requ = snapshot.value as? NSDictionary{
                                    for (k, v) in requ {
                                        if let dict = v as? [String: String]{
                                            print("\(k) + \(dict["request_status"])")
                                            
                                            if dict["request_status"] == "received" {
                                                temp.append(k as! String)
                                            
                                            }
                                            DispatchQueue.main.async {
                                                self?.friend = temp
                                                self?.friendlist.reloadData()
                                            }
                                            
//                                            if dict["request_status"] == "added" {
//                                                tempadd.append(k as! String)
//
//                                            }
//                                            DispatchQueue.main.async {
//                                                self?.acceptfriend = tempadd
//                                                self?.acceptFriendlist.reloadData()
//                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            })
                            
                            self?.ref.child("User").child(user!.uid).child("Friend").observe(.value, with: { snapshot in
                                var tempadd = [String]()

                                if let requ = snapshot.value as? NSDictionary {
                                    for (k, v) in requ {
                                    tempadd.append(k as! String)

                                    }
                                    
                                    DispatchQueue.main.async {
                                                                                        self?.acceptfriend = tempadd
                                                                                        self?.acceptFriendlist.reloadData()
                                                                                    }
                                    
                                }
                                
                                print("what's up")
                                
                            })
                            
                           

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

        postRefHandle = ref?.child("Articles").observe(.value, with: { (snapshot) in
            // Get user value
            if let users = snapshot.value as? NSDictionary {
            
                for (key, value) in users {
                    if let vv = value as? NSDictionary{
                        if vv["author"] as? String == userID {
                    print(value)
                        }
                    }
                }
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
//        ref?.removeObserver(withHandle: postRefHandle)
    }
    
    @IBAction func userlist(_ sender: Any) {
        //user list
        ref.child("User").observe(.value, with: {(snapshot) in
            if let users = snapshot.value as? NSDictionary {
                for (k, y) in users {
                    print(y)
                }
            }
            
            
        })
        
    }
    
    @IBAction func addFriend(_ sender: Any) {
        
        let friendId = "bgc0eWBL2tdgVtSBGIvaGl2bTmF2"
        let userID = Auth.auth().currentUser?.uid

        ref.child("Friend").child(userID!).child(friendId).child("request_status").setValue("send")
        ref.child("Friend").child(friendId).child(userID!).child("request_status").setValue("received")
    }
    
   
    
    
    
    func displayShareSheet(_ indexPath: IndexPath)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let userID = Auth.auth().currentUser?.uid

        let editAction = UIAlertAction(title: NSLocalizedString("Accept", comment: "Accept"), style: .default, handler: { (action) -> Void in
            
            self.ref.child("Friend").child(userID!).child(self.friend[indexPath.row]).child("request_status").setValue(nil)
            self.ref.child("Friend").child(self.friend[indexPath.row]).child(userID!).child("request_status").setValue(nil)
            self.ref.child("User").child(userID!).child("Friend").child(self.friend[indexPath.row]).setValue(self.useremail[self.friend[indexPath.row]])
            
            self.ref.child("User").child(self.friend[indexPath.row]).child("Friend").child(userID!).setValue(self.useremail[userID!])
            
            DispatchQueue.main.async {
                
                self.friend.remove(at: indexPath.row)
                
                self.friendlist.reloadData()
            }

//           self.acceptfriend.append(self.friend[indexPath.row])
//            self.friend.remove(at: indexPath.row)
//            self.friendlist.reloadData()
//            self.acceptFriendlist.reloadData()
//
            
            print("Send now button tapped for value \(indexPath.row)")
        })
        
        //delete comment
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .default, handler: { (action) -> Void in
            

            self.ref.child("Friend").child(userID!).child(self.friend[indexPath.row]).child("request_status").setValue("reject")
            self.ref.child("Friend").child(self.friend[indexPath.row]).child(userID!).child("request_status").setValue("reject")
            
            
            print("Delete button tapped for value \(indexPath.row)")
            
            
        })
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped \((indexPath.row))")
            
            
        })
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    @IBAction func findTag(_ sender: Any) {
        var tagarticle = [NSDictionary]()
        var timeList = [Int]()
        let searchedtag = searchedTag.text
        ref?.child("Articles").queryOrdered(byChild: "createdtime").queryStarting(atValue: Int(starttime.text!)).queryEnding(atValue: Int(endtime.text!)).observe(.value, with: { (snapshot) in
            // Get user value
            if let users = snapshot.value as? NSDictionary {
                
                for (key, value) in users {
                    if let vv = value as? NSDictionary, let tag = vv["tag"] as? String{
                        if  tag.contains(searchedtag!){
//                            print(value)
                            tagarticle.append(vv)
                            timeList.append(vv["createdtime"] as! Int)
                        }
                    }
                }
                
                 timeList.sort(by: { $0 > $1})
                for tag in tagarticle{
//                    print(tag.value(forKey: "createdtime"))
//                    print(tag)
                
                }
                
                for i in 0...timeList.count - 1 {
                    for tag in tagarticle{
                        if tag.value(forKey: "createdtime") as! Int == timeList[i] {
                        print(tag)
                        }
                        
                    }
                }
                
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
//        ref?.removeObserver(withHandle: postRefHandle)

    }
    
}

