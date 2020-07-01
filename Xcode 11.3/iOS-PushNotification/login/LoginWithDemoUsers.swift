//
//  ViewController.swift
//  Demo
//
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import UIKit
import Firebase
import CometChatPro

class LoginWithDemoUsers: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var superHero1View: UIView!
    @IBOutlet weak var superHero2View: UIView!
    @IBOutlet weak var superHero3View: UIView!
    @IBOutlet weak var superHero4View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }
    
    
    fileprivate func addObservers(){
        let tapOnSuperHero1 = UITapGestureRecognizer(target: self, action: #selector(LoginWithSuperHero1(tapGestureRecognizer:)))
        superHero1View.isUserInteractionEnabled = true
        superHero1View.addGestureRecognizer(tapOnSuperHero1)
        
        let tapOnSuperHero2 = UITapGestureRecognizer(target: self, action: #selector(LoginWithSuperHero2(tapGestureRecognizer:)))
        superHero2View.isUserInteractionEnabled = true
        superHero2View.addGestureRecognizer(tapOnSuperHero2)
        
        let tapOnSuperHero3 = UITapGestureRecognizer(target: self, action: #selector(LoginWithSuperHero3(tapGestureRecognizer:)))
        superHero3View.isUserInteractionEnabled = true
        superHero3View.addGestureRecognizer(tapOnSuperHero3)
        
        let tapOnSuperHero4 = UITapGestureRecognizer(target: self, action: #selector(LoginWithSuperHero4(tapGestureRecognizer:)))
        superHero4View.isUserInteractionEnabled = true
        superHero4View.addGestureRecognizer(tapOnSuperHero4)
    }
    
    @objc func LoginWithSuperHero1(tapGestureRecognizer: UITapGestureRecognizer)
    {
        loginWithUID(UID: "superhero1")
    }
    
    @objc func LoginWithSuperHero2(tapGestureRecognizer: UITapGestureRecognizer)
    {
        loginWithUID(UID: "superhero2")
    }
    
    @objc func LoginWithSuperHero3(tapGestureRecognizer: UITapGestureRecognizer)
    {
        loginWithUID(UID: "superhero3")
    }
    
    @objc func LoginWithSuperHero4(tapGestureRecognizer: UITapGestureRecognizer)
    {
        loginWithUID(UID: "superhero4")
    }
    
    
    private  func loginWithUID(UID:String){
        
        if(Constants.apiKey.contains(NSLocalizedString("Enter", comment: "")) || Constants.apiKey.contains(NSLocalizedString("ENTER", comment: "")) || Constants.apiKey.contains("NULL") || Constants.apiKey.contains("null") || Constants.apiKey.count == 0){
            showAlert(title: NSLocalizedString("Warning!", comment: ""), msg: NSLocalizedString("Please fill the APP-ID and API-KEY in Constants.swift file.", comment: ""))
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            CometChat.login(UID: UID, apiKey: Constants.apiKey, onSuccess: { (current_user) in
                let userID:String = current_user.uid!
                let userTopic: String = Constants.appID + "_user_" + userID + "_ios"
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                UserDefaults.standard.set(current_user.uid, forKey: "LoggedInUserID")
                UserDefaults.standard.set(userTopic, forKey: "firebase_user_topic")
                Messaging.messaging().subscribe(toTopic: userTopic) { error in
                    print("Subscribed to \(userTopic) topic")
                }
                let groupTopic: String = Constants.appID + "_group_" + Constants.toGroupUID + "_ios"
                
                UserDefaults.standard.set(groupTopic, forKey: "firebase_group_topic")
                Messaging.messaging().subscribe(toTopic: groupTopic) { error in
                    print("Subscribed to \(groupTopic) topic")
                }
                DispatchQueue.main.async {self.activityIndicator.stopAnimating()
                    print("login Sucess with Superhero4: \(current_user.stringValue())")
                    self.performSegue(withIdentifier: "presentPushNotification", sender: nil)
                }
                
            }) { (error) in
                DispatchQueue.main.async { self.activityIndicator.stopAnimating()}
                print("login failure \(error)")
            }
        }
    }
}


extension UIViewController {
    func showAlert(title : String?, msg : String,
                   style: UIAlertController.Style = .alert,
                   dontRemindKey : String? = nil) {
        if dontRemindKey != nil,
            UserDefaults.standard.bool(forKey: dontRemindKey!) == true {
            return
        }
        
        let ac = UIAlertController.init(title: title,
                                        message: msg, preferredStyle: style)
        ac.addAction(UIAlertAction.init(title: "OK",
                                        style: .default, handler: nil))
        
        if dontRemindKey != nil {
            ac.addAction(UIAlertAction.init(title: "Don't Remind",
                                            style: .default, handler: { (aa) in
                                                UserDefaults.standard.set(true, forKey: dontRemindKey!)
                                                UserDefaults.standard.synchronize()
            }))
        }
        DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
        }
    }
}
