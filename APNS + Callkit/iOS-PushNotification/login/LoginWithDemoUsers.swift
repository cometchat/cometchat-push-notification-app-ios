//
//  ViewController.swift
//  Demo
//
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import UIKit
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
            showAlert(title: NSLocalizedString("Warning!", comment: ""), msg: NSLocalizedString("Please fill the APP-ID and API-KEY in Constants.swift file.", comment: ""))
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            CometChat.login(UID: UID, apiKey: Constants.authKey, onSuccess: { (current_user) in
                
                DispatchQueue.main.async {
                    if let apnsToken = UserDefaults.standard.value(forKey: "apnsToken") as?  String {
                        print("APNS token is: \(apnsToken)")
                        CometChat.registerTokenForPushNotification(token: apnsToken, settings: ["voip":false]) { (success) in
                            print("onSuccess to  registerTokenForPushNotification: \(success)")
                            
                        } onError: { (error) in
                            print("error to registerTokenForPushNotification")
                        }
                    }
                    if let voipToken = UserDefaults.standard.value(forKey: "voipToken") as?  String {
                        print("VOIP token is: \(voipToken)")
                        CometChat.registerTokenForPushNotification(token: voipToken, settings: ["voip":true]) { (success) in
                            print("onSuccess to  registerTokenForPushNotification: \(success)")
                            
                        } onError: { (error) in
                            print("error to registerTokenForPushNotification")
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "pushNotification") as! PushNotification
                        let navigationController: UINavigationController = UINavigationController(rootViewController: mainVC)
                        navigationController.modalPresentationStyle = .fullScreen
                        navigationController.title = "Push Notification"
                        navigationController.navigationBar.prefersLargeTitles = true
                        if #available(iOS 13.0, *) {
                            let navBarAppearance = UINavigationBarAppearance()
                            navBarAppearance.configureWithOpaqueBackground()
                            navBarAppearance.shadowColor = .clear
                            navBarAppearance.backgroundColor = .systemBackground
                            navigationController.navigationBar.standardAppearance = navBarAppearance
                            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
                            self.navigationController?.navigationBar.isTranslucent = false
                        }
                        self.present(navigationController, animated: true, completion: nil)
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


