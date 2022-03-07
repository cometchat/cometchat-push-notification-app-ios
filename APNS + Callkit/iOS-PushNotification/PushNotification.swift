//
//  PushNotification.swift
//  iOS-PushNotification
//
//  Created by Admin1 on 29/03/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro
import CallKit
import PushKit

class PushNotification: UIViewController , UITextViewDelegate {
    
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
    var call: Call?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector:#selector(self.didReceivedIncomingCall(_:)), name: NSNotification.Name(rawValue: "didReceivedIncomingCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didAcceptButtonPressed(_:)), name: NSNotification.Name(rawValue: "didAcceptButtonPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRejectButtonPressed(_:)), name: NSNotification.Name(rawValue: "didRejectButtonPressed"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didReceivedMessageFromGroup(_:)), name: NSNotification.Name(rawValue: "didReceivedMessageFromGroup"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didReceivedMessageFromUser(_:)), name: NSNotification.Name(rawValue: "didReceivedMessageFromUser"), object: nil)
        
        self.setupAppearance()
        self.registerDelegates()
    }
    
    @objc func didReceivedMessageFromGroup(_ notification: NSNotification) {
            if let group = notification.userInfo?["group"] as? Group {
                DispatchQueue.main.async {
                 let messageList = CometChatMessageList()
                 let navigationController = UINavigationController(rootViewController:messageList)
                  messageList.set(conversationWith: group, type: .group)
                  self.present(navigationController, animated:true, completion:nil)
                }
            }
        }
        
        @objc func didReceivedMessageFromUser(_ notification: NSNotification) {
              print("didReceivedMessageFromUser")
            if let user = notification.userInfo?["user"] as? User {
                DispatchQueue.main.async {
                 let messageList = CometChatMessageList()
                 let navigationController = UINavigationController(rootViewController:messageList)
                  messageList.set(conversationWith: user, type: .user)
                  self.present(navigationController, animated:true, completion:nil)
                }
            }
        }
    
    @objc func didReceivedIncomingCall(_ notification: NSNotification) {
            if let currentCall = notification.userInfo?["call"] as? Call {
                self.call = currentCall
            }
        
//        if let currentCall = call {
//            let incomingCall = CometChatIncomingCall()
//            incomingCall.acceptCall(withCall: currentCall)
//            incomingCall.modalPresentationStyle = .fullScreen
//            self.present(incomingCall, animated: true, completion: nil)
//        }
     }
    
    @objc func didAcceptButtonPressed(_ notification: NSNotification) {
        if let currentCall = call {
            let incomingCall = CometChatIncomingCall()
            incomingCall.acceptCall(withCall: currentCall)
            incomingCall.modalPresentationStyle = .fullScreen
            self.present(incomingCall, animated: true, completion: nil)
        }
     }
    
    @objc func didRejectButtonPressed(_ notification: NSNotification) {
        if let currentCall = call {
            CometChat.rejectCall(sessionID: currentCall.sessionID ?? "", status: .rejected) { (call) in
                
            } onError: { (error) in
                
            }
        }
     }

    
    private func registerDelegates() {
        CometChat.messagedelegate = self
        CometChat.calldelegate = self
        textMessageField.delegate = self
    }
    func setupAppearance(){
        
        //ButtonAppearance
        sendButton.layer.cornerRadius = 12
        customMessageBtn.layer.cornerRadius = 12
        audioCallBtn.layer.cornerRadius = 12
        videoCallBtn.layer.cornerRadius = 12
        UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
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
            
            textMessage  = TextMessage(receiverUid: UID!, text: self.textMessageField.text ?? "", receiverType: receiverType)
            
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                print("sendTextMessage onSuccess \(message.stringValue())")
                DispatchQueue.main.async{
                    self.textMessageField.text = ""
                    self.sendButton.setTitle("Notification Sent", for: .normal)
                    self.sendButton.backgroundColor = #colorLiteral(red: 0.3361090664, green: 0.8566188135, blue: 0.01250887299, alpha: 1)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendButton.setTitle("Text Message", for: .normal)
                    self.sendButton.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                }
                
            }) { (error) in
                print("sendTextMessage failure \(String(describing: error?.errorDescription))")
                DispatchQueue.main.async{
                    
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error!.errorDescription, duration: .short)
                    snackbar.show()
                    
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
        
        let message:String = textMessageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
               
               if(message.count == 0 || message.isEmpty || UID!.isEmpty || UID!.count == 0 || UID!.contains("nil")){
                   
                   showAlert(title: "Warning!", msg: "Please, fill the required parameters")
               }else{
                   
                
        let customNotificationDisplayText = ["pushNotification": "Custom Notification Received"]
        
        customMessage = CustomMessage(receiverUid: UID!, receiverType: receiverType, customData: ["customMessage":message], type: "custom")
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
                self.customMessageBtn.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
            }
            
        }) { (error) in
            print("sendCustomMessage failure \(String(describing: error?.errorDescription))")
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error!.errorDescription, duration: .short)
                snackbar.show()
                self.customMessageBtn.setTitle("Notification failure", for: .normal)
                self.customMessageBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            }
        }
    }
    }
    
    @IBAction func audioCallBtnPressed(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
            UID = Constants.toGroupUID
        }
        
        if( UID!.isEmpty || UID!.count == 0 || UID!.contains("nil")){
            
            showAlert(title: "Warning!", msg: "Please, fill the required parameters")
            
        }else{
            
            CometChat.getUser(UID: UID!) { (user) in
                DispatchQueue.main.async{
                    if let user = user {
                        CometChatCallManager().makeCall(call: .audio, to: user)
                        DispatchQueue.main.async{
                            self.textMessageField.text = ""
                            self.audioCallBtn.setTitle("Notification Sent", for: .normal)
                            self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.3361090664, green: 0.8566188135, blue: 0.01250887299, alpha: 1)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.audioCallBtn.setTitle("Audio Call", for: .normal)
                            self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                        }
                    }
               
                }
            } onError: { (error) in
                
                print("Call initialization failed with error:  " + error!.errorDescription);
                DispatchQueue.main.async{
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error!.errorDescription, duration: .short)
                    snackbar.show()
                    self.audioCallBtn.setTitle("Notification failure", for: .normal)
                    self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
        }
    }
    
    
    @IBAction func videoCallBtnPressed(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            UID = (UIDTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "nil")
        }else{
            UID = Constants.toGroupUID
        }
        
        if( UID!.isEmpty || UID!.count == 0 || UID!.contains("nil")){
            
            showAlert(title: "Warning!", msg: "Please, fill the required parameters")
        }else{
            
            CometChat.getUser(UID: UID!) { (user) in
                DispatchQueue.main.async{
                    if let user = user {
                        CometChatCallManager().makeCall(call: .video, to: user)
                        DispatchQueue.main.async{
                            self.textMessageField.text = ""
                            self.audioCallBtn.setTitle("Notification Sent", for: .normal)
                            self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.3361090664, green: 0.8566188135, blue: 0.01250887299, alpha: 1)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.audioCallBtn.setTitle("Audio Call", for: .normal)
                            self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                        }
                    }
               
                }
            } onError: { (error) in
                
                print("Call initialization failed with error:  " + error!.errorDescription);
                DispatchQueue.main.async{
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error!.errorDescription, duration: .short)
                    snackbar.show()
                    self.audioCallBtn.setTitle("Notification failure", for: .normal)
                    self.audioCallBtn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        self.sendButton.setTitle("Text Message", for: .normal)
        self.sendButton.backgroundColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        super.touchesBegan(touches, with: event)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textMessageField.text = ""
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        if let UID = CometChat.getLoggedInUser()?.uid {
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout \(String(describing: UID)) ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    CometChat.logout(onSuccess: { (success) in
                        let login = self.storyboard?.instantiateViewController(withIdentifier: "loginWithDemoUsers") as! LoginWithDemoUsers
                        login.modalPresentationStyle = .fullScreen
                        self.present(login, animated: true, completion: nil)
                        
                    }) { (error) in
                        DispatchQueue.main.async{
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error.errorDescription, duration: .short)
                            snackbar.show()
                        }
                    }
                    
                case .cancel: break
                case .destructive: break
                }}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
       
    }
    
}


extension PushNotification: CometChatMessageDelegate {

    func onTextMessageReceived(textMessage: TextMessage) {
        switch textMessage.receiverType {
        case .user:
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Text Message Received: \(textMessage.text)", duration: .short)
                snackbar.show()
            }
        case .group:
            DispatchQueue.main.async{
                if let group = (textMessage.receiver as? Group)?.name {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Text Message Received in \(group): \(textMessage.text)", duration: .short)
                    snackbar.show()
                }
            }
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Text Message Received in \(String(describing: (textMessage.receiver as? Group)?.name)): \(textMessage.text)", duration: .short)
                snackbar.show()
            }
        @unknown default: break
        }
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        switch mediaMessage.receiverType {
        case .user:
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Media Message Received: \(mediaMessage.messageType.rawValue)", duration: .short)
                snackbar.show()
            }
        case .group:
            DispatchQueue.main.async{
                if let group = (mediaMessage.receiver as? Group)?.name {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Media Message Received in \(group): \(mediaMessage.messageType.rawValue)", duration: .short)
                snackbar.show()
                }
            }
        @unknown default: break
        }
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        switch customMessage.receiverType {
        case .user:
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Custom Message Received: \(String(describing: customMessage.customData))", duration: .short)
                snackbar.show()
            }
        case .group:
            DispatchQueue.main.async{
                if let group = (customMessage.receiver as? Group)?.name {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Custom Message Received in \(group): \(String(describing: customMessage.customData))", duration: .short)
                    snackbar.show()
                }
            }
        @unknown default: break
        }
    }
    
 
}

extension PushNotification:  CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
        switch incomingCall?.receiverType {
        case .user:
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Incoming Call Received", duration: .short)
                snackbar.show()
            }
        case .group:
            DispatchQueue.main.async{
                if let group = (incomingCall?.receiver as? Group)?.name {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Incoming Call Received in \(group)", duration: .short)
                snackbar.show()
            }
            }
        @unknown default: break
        }
    }
    
    func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
        switch canceledCall?.receiverType {
        case .user:
            DispatchQueue.main.async{
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Incoming Call Cancelled", duration: .short)
                snackbar.show()
            }
        case .group:
            DispatchQueue.main.async{
                if let group = (canceledCall?.receiver as? Group)?.name {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Incoming Call Cancelled in \(group))", duration: .short)
                snackbar.show()
                }
            }
        @unknown default: break
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
        DispatchQueue.main.async{
            if let call = acceptedCall {
                CometChatCallManager.outgoingCallDelegate?.onOutgoingCallAccepted(acceptedCall: call, error: error)
            }
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Accepted", duration: .short)
            snackbar.show()
        }
    }
    
    func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
        DispatchQueue.main.async{
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Rejected", duration: .short)
            snackbar.show()
        }
    }
    
    
}

extension PushNotification:  CXProviderDelegate {

    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    
}
