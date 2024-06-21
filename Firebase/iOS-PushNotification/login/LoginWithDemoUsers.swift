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

    @IBOutlet weak var typePN: UISegmentedControl!
    
    @IBOutlet weak var loginButtons: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButtons.axis = .vertical
                        self.loginButtons.alignment = .fill
                        self.loginButtons.distribution = .fillEqually
                        self.loginButtons.spacing = 10 // Optional: Add spacing between views
                        self.loginButtons.translatesAutoresizingMaskIntoConstraints = false
                        fetchSampleLoginData()
    }
    
    
  
    private  func loginWithUID(UID:String){
        
        if(Constants.apiKey.contains(NSLocalizedString("Enter", comment: "")) || Constants.apiKey.contains(NSLocalizedString("ENTER", comment: "")) || Constants.apiKey.contains("NULL") || Constants.apiKey.contains("null") || Constants.apiKey.count == 0){
            showAlert(title: NSLocalizedString("Warning!", comment: ""), msg: NSLocalizedString("Please fill the APP-ID and API-KEY in Constants.swift file.", comment: ""))
        }else{
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            CometChat.login(UID: UID, apiKey: Constants.apiKey, onSuccess: { (current_user) in
               
                
                DispatchQueue.main.async {
                if self.typePN.selectedSegmentIndex == 0 {
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
                }else{
                    
                    if let token = UserDefaults.standard.value(forKey: "fcmToken") as?  String {
                        print("Reached here for token: \(token)")
                        CometChat.registerTokenForPushNotification(token: token, onSuccess: { (success) in
                            print("onSuccess to  registerTokenForPushNotification: \(success)")
                            
                            DispatchQueue.main.async {self.activityIndicator.stopAnimating()
                                print("login Sucess with : \(current_user.stringValue())")
                                self.performSegue(withIdentifier: "presentPushNotification", sender: nil)
                            }
                            
                        }) { (error) in
                            print("error to registerTokenForPushNotification")
                        }
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
    
    func fetchSampleLoginData(){
          let url = URL(string: "https://assets.cometchat.io/sampleapp/sampledata.json")!
            URLSession.shared.fetchData(for: url) { (result: Result<SampleUsers, Error>) in
              switch result {
              case .success(let users):
                  self.constructLoginButtons(users.users)

              case .failure(let error):
                  if let data = self.loadJson(filename: "sample_user_data"){
                      self.constructLoginButtons(data.users)
                  } else {
                      print("error occured is \(error.localizedDescription)")
                  }

            }
          }
      }

      func constructLoginButtons(_ users : [SampleUser]){
          DispatchQueue.main.async {
              var count = 0
              var row = UIStackView()
              row.axis = .horizontal
              row.alignment = .fill
              row.distribution = .equalSpacing
              row.spacing = 2 // Optional: Add spacing between views
              row.translatesAutoresizingMaskIntoConstraints = false
              for user in users{
                  count+=1
                  // Create the background view
                          let backgroundView = UIView()
                          backgroundView.translatesAutoresizingMaskIntoConstraints = false
                  backgroundView.backgroundColor = .black
                          backgroundView.layer.cornerRadius = 15.0

                          backgroundView.layer.masksToBounds = true // Ensure the corners are clipped

                  let customButton = CustomLoginButton()
                      .set(title: user.name)
                      .set(subtitle: user.uid)
                      .set(avatar: user.avatar)
                      .set(onTap: { [weak self] in
                          guard let this = self else { return }
                          this.loginWithUID(UID: user.uid)
                      })


                  backgroundView.addSubview(customButton)

                  row.addArrangedSubview(backgroundView)
                  // Set constraints for the background view
                        NSLayoutConstraint.activate([
                            backgroundView.widthAnchor.constraint(equalToConstant: 171.8),
                            backgroundView.heightAnchor.constraint(equalToConstant: 55)
                        ])

                        // Set constraints for the button to match the size of the background view
                        NSLayoutConstraint.activate([
                            customButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                            customButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                            customButton.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                            customButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
                        ])

                  if count%2==0 {
                      self.loginButtons.addArrangedSubview(row)
                      row = UIStackView()
                      row.axis = .horizontal
                      row.alignment = .fill
                      row.distribution = .equalSpacing
                      row.spacing = 2 // Optional: Add spacing between views
                      row.translatesAutoresizingMaskIntoConstraints = false

		      if count==4 {
  			break
		      }
                  }
              }

              if count%2 != 0{
                  row.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 152, height: 50)))
                  self.loginButtons.addArrangedSubview(row)
              }

          }
      }

      func loadJson(filename fileName: String) -> SampleUsers? {
          if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
              do {
                  let data = try Data(contentsOf: url)
                  let decoder = JSONDecoder()
                  let jsonData = try decoder.decode(SampleUsers.self, from: data)
                  return jsonData
              } catch {
                  print("error occurred while loading JSON:\(error.localizedDescription)")
              }
          }
          return nil
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
