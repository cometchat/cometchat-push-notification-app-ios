//
//  PushNotificationVC.swift
//  iOS-PushNotification
//
//  Created by Admin1 on 29/03/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import Firebase

class PushNotificationVC: UIViewController , UITextViewDelegate{
    
    //OutLets Declarations
    
    @IBOutlet weak var textMessageField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var UIDTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var customMessageBtn: UIButton!
    @IBOutlet weak var audioCallBtn: UIButton!
    @IBOutlet weak var videoCallBtn: UIButton!
    
    //Variable Declarations
    var activeTextview: UITextView?
    var textMessage: TextMessage?
    var customMessage: CustomMessage?
    var receiverType:CometChat.ReceiverType = .user
    var UID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        //Assigning Delegates
        textMessageField.delegate = self
        
        
        //Function Calling
        handlePushNotificationVCApperance()
    }
    
    func handlePushNotificationVCApperance(){
        
        //ButtonAppearance
        textMessageField.layer.cornerRadius = 5
        sendButton.layer.cornerRadius = 5
        customMessageBtn.layer.cornerRadius = 5
        audioCallBtn.layer.cornerRadius = 5
        videoCallBtn.layer.cornerRadius = 5
        
    }
    
    @IBAction func segmentControlPressed(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            receiverType = .user
        }else{
            receiverType = .group
        }
    }
    
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
             UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
             UID = Constants.toGroupUID
        }
        
        let message:String = textMessageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(message.count == 0 || message.isEmpty || UID!.isEmpty || UID!.count == 0 || UID!.contains("nil")){
            
            showAlert(title: "Warning!", msg: "Please, fill the required parameters")
        }else{

        textMessage  = TextMessage(receiverUid: UID!, text: self.textMessageField.text ?? "", messageType: .text, receiverType: receiverType)
        
        CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
            print("sendTextMessage onSuccess \(message.stringValue())")
            DispatchQueue.main.async{
                self.textMessageField.text = ""
                self.sendButton.setTitle("Notification Sent", for: .normal)
                self.sendButton.backgroundColor = #colorLiteral(red: 0.3361090664, green: 0.8566188135, blue: 0.01250887299, alpha: 1)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sendButton.setTitle("Text Message", for: .normal)
                self.sendButton.backgroundColor = #colorLiteral(red: 0.4784313725, green: 0.3529411765, blue: 0.6509803922, alpha: 1)
            }
            
        }) { (error) in
            print("sendTextMessage failure \(String(describing: error?.errorDescription))")
            DispatchQueue.main.async{
                self.view.makeToast("\(String(describing: error!.errorDescription))")
                self.sendButton.setTitle("Notification failure", for: .normal)
                self.sendButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
        }
    }
}
    
    @IBAction func sendCustomMessge(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
            UID = Constants.toGroupUID
        }
        
            let customNotificationDisplayText = ["pushNotification": "Custom Notification Received"]
        
        customMessage = CustomMessage(receiverUid: UID!, receiverType: receiverType, customData: ["customMessage":"Hello World"])
            customMessage?.metaData = customNotificationDisplayText
        
            CometChat.sendCustomMessage(message: customMessage!, onSuccess: { (customMessage) in
                
                print("sendCustomMessage onSuccess \(customMessage.stringValue())")
                DispatchQueue.main.async{
                    self.textMessageField.text = ""
                    self.customMessageBtn.setTitle("Notification Sent", for: .normal)
                    self.customMessageBtn.backgroundColor = #colorLiteral(red: 0.3361090664, green: 0.8566188135, blue: 0.01250887299, alpha: 1)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.customMessageBtn.setTitle("Custom Message", for: .normal)
                    self.customMessageBtn.backgroundColor = #colorLiteral(red: 0.4784313725, green: 0.3529411765, blue: 0.6509803922, alpha: 1)
                }
                
            }) { (error) in
                print("sendCustomMessage failure \(String(describing: error?.errorDescription))")
                DispatchQueue.main.async{
                    self.view.makeToast("\(String(describing: error!.errorDescription))")
                    self.customMessageBtn.setTitle("Notification failure", for: .normal)
                    self.customMessageBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
    }
    
    @IBAction func audioCallBtnPressed(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
            UID = Constants.toGroupUID
        }
        
        let newCall = Call(receiverId: UID!, callType: .audio, receiverType: receiverType)
        
        CometChat.initiateCall(call: newCall, onSuccess: { (ongoing_call) in
            
            print("Call initiated successfully: " + ongoing_call!.stringValue());
            
        }) { (error) in
            
            print("Call initialization failed with error:  " + error!.errorDescription);
            
        }
        
    }
    
    
    @IBAction func videoCallBtnPressed(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
            UID = Constants.toGroupUID
        }
        
        let newCall = Call(receiverId: UID!, callType: .video, receiverType: receiverType)
        
        CometChat.initiateCall(call: newCall, onSuccess: { (ongoing_call) in
            
            print("Call initiated successfully " + ongoing_call!.stringValue());
            
        }) { (error) in
            
            print("Call initialization failed with error:  " + error!.errorDescription);
            
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        self.sendButton.setTitle("Text Message", for: .normal)
        self.sendButton.backgroundColor = #colorLiteral(red: 0.4784313725, green: 0.3529411765, blue: 0.6509803922, alpha: 1)
        super.touchesBegan(touches, with: event)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textMessageField.text = ""
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let UID = UserDefaults.standard.object(forKey: "LoggedInUserID")
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout \(String(describing: UID!)) ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                CometChat.logout(onSuccess: { (success) in
                    let userTopic = UserDefaults.standard.object(forKey: "firebase_user_topic")
                    let groupTopic = UserDefaults.standard.object(forKey: "firebase_group_topic")
                    Messaging.messaging().unsubscribe(fromTopic: userTopic as! String)
                    Messaging.messaging().unsubscribe(fromTopic: groupTopic as! String)
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "startupVC") as! startupVC
                    self.present(vc, animated: true, completion: nil)
                    
                }) { (error) in
                    
                    
                }
                
            case .cancel: break
                
            case .destructive: break
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
