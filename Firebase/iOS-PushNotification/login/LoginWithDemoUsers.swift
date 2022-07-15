//  ViewController.swift
//  Demo
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.

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
        
        if(Constants.authKey.contains(NSLocalizedString("Enter", comment: "")) || Constants.authKey.contains(NSLocalizedString("ENTER", comment: "")) || Constants.authKey.contains("NULL") || Constants.authKey.contains("null") || Constants.authKey.count == 0){
            showAlert(title: NSLocalizedString("Warning!", comment: ""), msg: NSLocalizedString("Please fill the APP-ID and AUTH-KEY in Constants.swift file.", comment: ""))
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            CometChat.login(UID: UID, authKey: Constants.authKey, onSuccess: { (current_user) in
               
                
                DispatchQueue.main.async {
                    if let token = UserDefaults.standard.value(forKey: "fcmToken") as?  String {
                        print("Reached here for token: \(token)")
                        CometChat.registerTokenForPushNotification(token: token, onSuccess: { (success) in
                            print("onSuccess to  registerTokenForPushNotification: \(success)")

                            DispatchQueue.main.async {self.activityIndicator.stopAnimating()
                                print("login Sucess with Superhero4: \(current_user.stringValue())")
                                self.performSegue(withIdentifier: "presentPushNotification", sender: nil)
                            }
                        }) { (error) in
                            print("error to registerTokenForPushNotification")
                        }
                    }

                }
            }) { (error) in
                
                DispatchQueue.main.async { self.activityIndicator.stopAnimating()}
                DispatchQueue.main.async {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error.errorDescription, duration: .short)
                    snackbar.show()
                }
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
