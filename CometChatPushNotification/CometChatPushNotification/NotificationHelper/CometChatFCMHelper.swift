//
//  CometChatPNHelper.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import CometChatCallsSDK
import Firebase

class CometChatFCMHelper {
    
    //Start For APNs Push notification
    public func configurePushNotification(application: UIApplication, delegate: MessagingDelegate) {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = delegate
        
        CometChat.addLoginListener("loginlistener-pnToken-register-login", self)
        
    }
    
    
    public func registerTokenForPushNotification(deviceToken: Data) {
        
        guard CometChat.getLoggedInUser() != nil else {
            return
        }
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexString, forKey: "apnspuToken")
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                return
            }
            
            guard let fcmToken = token else {
                print("No FCM token available")
                return
            }
            
            let pushToken = fcmToken
            let platform = CometChatNotifications.PushPlatforms.FCM_IOS
            let providerId = "Enter your FCM provider ID here"
            
            CometChatNotifications.registerPushToken(
                pushToken: pushToken,
                platform: platform,
                providerId: providerId,
                onSuccess: { (success) in
                    print("registerPushToken: \(success)")
                }) { (error) in
                    print("registerPushToken: \(error.errorCode) \(error.errorDescription)")
                }
        }
    }
    //end for APNs Push notification
    
    
    public func presentMessageFromPayload(response:  UNNotificationResponse) {
        let notification = response.notification.request.content.userInfo as? [String: Any]
        
        //For Presenting Message
        if let userInfo = notification, let messageObject =
            userInfo["message"], let dict = messageObject as? [String: Any] {
            
            let message = CometChat.processMessage(dict).0
            
            let cometChatMessages = CometChatMessages()
            if message?.receiverType == .user {
                guard let uid = message?.senderUid, let userName = message?.sender?.name else { return }
                let user = User(uid: uid, name: userName)
                cometChatMessages.set(user: user)
            }else {
                guard let group = (message?.receiver as? Group)else { return }
                cometChatMessages.set(group: group)
            }
            
            cometChatMessages.modalPresentationStyle = .fullScreen
            presentVCFromRootView(vc: cometChatMessages)
            
        }
        
        //For Presenting call
        if let userInfo = notification, let messageString =
            userInfo["message"] as? String {
            
            if let callObject = convertToDictionary(text: messageString) {
                if let messageObject = CometChat.processMessage(callObject).0 {
                    if messageObject.messageCategory == .call {
                        if let call = messageObject as? Call {
                            if call.callStatus == .initiated {
                                let incomingCallView = CometChatIncomingCall()
                                incomingCallView.set(call: call)
                                incomingCallView.modalPresentationStyle = .fullScreen
                                presentVCFromRootView(vc: incomingCallView)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func presentVCFromRootView(vc: UIViewController){
        
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
        if let window = sceneDelegate?.window, let rootViewController = window.rootViewController {
            var currentController = rootViewController
            while let presentedController = currentController.presentedViewController {
                currentController = presentedController
            }
            currentController.present(vc, animated: true)
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

//MARK: Login Token handling
extension CometChatFCMHelper: CometChatLoginDelegate {
    
    func onLoginSuccess(user: CometChatSDK.User) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func onLoginFailed(error: CometChatSDK.CometChatException?) {  return }
    
    func onLogoutSuccess() { return }
    
    func onLogoutFailed(error: CometChatSDK.CometChatException?) { return }
    
    
}
