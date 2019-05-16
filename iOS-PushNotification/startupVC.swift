//
//  ViewController.swift
//  iOS-PushNotification
//
//  Created by Admin1 on 29/03/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import Firebase

class startupVC: UIViewController {
    
    //Variable Declarations
    

    //Outlets Declarations
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var superhero1: UIButton!
    @IBOutlet weak var superhero2: UIButton!
    @IBOutlet weak var superhero3: UIButton!
    @IBOutlet weak var superhero4: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function Calling
        handleStartUpVCApperance()
    }
    
    func handleStartUpVCApperance(){
        
        //activityIndicator
        activityIndicator.isHidden = true
        
        //ButtonAppearance
        superhero1.layer.cornerRadius = 5
        superhero2.layer.cornerRadius = 5
        superhero3.layer.cornerRadius = 5
        superhero4.layer.cornerRadius = 5
    }

    @IBAction func loginWithSuperhero1(_ sender: Any) {
       
        self.loginWithUID(UID: "superhero1")
    }
    
    @IBAction func loginWithSuperhero2(_ sender: Any) {
        
        self.loginWithUID(UID: "superhero2")
        
    }
    
    @IBAction func loginWithSuperhero3(_ sender: Any) {
        
        self.loginWithUID(UID: "superhero3")
    }
    
    
    @IBAction func loginWithSuperhero4(_ sender: Any) {
        
        self.loginWithUID(UID: "superhero4")
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
            self.activityIndicator.stopAnimating()
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
            DispatchQueue.main.async {self.activityIndicator.stopAnimating()}
            print("login Sucess with Superhero4: \(current_user.stringValue())")
            self.performSegue(withIdentifier: "presentPushNotificationVC", sender: nil)
            
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
